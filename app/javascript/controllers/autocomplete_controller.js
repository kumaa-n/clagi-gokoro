import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    url: String,
    field: String,
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.debounceTimeout = null
    this.abortController = null
    this.selectedIndex = -1 // 選択中の候補のインデックス
  }

  disconnect() {
    this.clearDebounce()
    this.abortRequest()
  }

  // 入力時の処理
  onInput(event) {
    const query = event.target.value.trim()

    // 入力がない場合は候補を非表示
    if (query === "") {
      this.hideResults()
      return
    }

    // 既存のdebounceタイマーをクリア
    this.clearDebounce()

    // debounce処理：指定時間後に検索を実行
    this.debounceTimeout = setTimeout(() => {
      this.search(query)
    }, this.debounceDelayValue)
  }

  // キーボード操作の処理
  onKeydown(event) {
    // 候補リストが非表示の場合は何もしない
    if (this.resultsTarget.classList.contains("hidden")) {
      return
    }

    const items = this.resultsTarget.querySelectorAll("li")
    if (items.length === 0) {
      return
    }

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateSelection(items)
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection(items)
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          const selectedItem = items[this.selectedIndex]
          this.inputTarget.value = selectedItem.dataset.value
          this.hideResults()
        }
        break
      case "Escape":
        event.preventDefault()
        this.hideResults()
        break
    }
  }

  // 選択状態を更新
  updateSelection(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add("bg-primary/20")
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.classList.remove("bg-primary/20")
      }
    })
  }

  // サーバーに検索リクエストを送信
  async search(query) {
    // 既存のリクエストをキャンセル
    this.abortRequest()

    // 新しいAbortControllerを作成
    this.abortController = new AbortController()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("field", this.fieldValue)
      url.searchParams.set("query", query)

      const response = await fetch(url, {
        signal: this.abortController.signal,
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const results = await response.json()
      this.displayResults(results)
    } catch (error) {
      // AbortErrorは無視（意図的なキャンセル）
      if (error.name !== "AbortError") {
        this.hideResults()
      }
    }
  }

  // 検索結果を表示
  displayResults(results) {
    if (results.length === 0) {
      this.hideResults()
      return
    }

    // 選択インデックスをリセット
    this.selectedIndex = -1

    // 結果リストを構築
    const items = results.map(result => {
      const li = document.createElement("li")
      li.textContent = result
      li.classList.add(
        "px-4", "py-2", "cursor-pointer", "hover:bg-primary/10",
        "transition-colors", "text-neutral"
      )
      li.dataset.action = "click->autocomplete#selectResult"
      li.dataset.value = result
      return li
    })

    // 既存の結果をクリアして新しい結果を追加
    this.resultsTarget.innerHTML = ""
    items.forEach(item => this.resultsTarget.appendChild(item))

    this.showResults()
  }

  // 候補を選択
  selectResult(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.hideResults()

    // 入力フィールドにフォーカスを戻す
    this.inputTarget.focus()
  }

  // 候補リストを表示
  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  // 候補リストを非表示
  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
  }

  // 入力フィールドからフォーカスが外れた時
  onBlur() {
    // クリックイベントが発火する前に非表示にならないよう、少し遅延
    setTimeout(() => {
      this.hideResults()
    }, 200)
  }

  // debounceタイマーをクリア
  clearDebounce() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
      this.debounceTimeout = null
    }
  }

  // 進行中のリクエストをキャンセル
  abortRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }
}
