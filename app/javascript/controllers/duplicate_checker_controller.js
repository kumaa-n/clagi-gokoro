import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "composer", "arranger", "warning"]
  static values = {
    url: String,
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.debounceTimeout = null
    this.abortController = null
  }

  disconnect() {
    this.clearDebounce()
    this.abortRequest()
  }

  // いずれかのフィールドが変更されたときに呼ばれる
  checkDuplicate() {
    this.clearDebounce()

    // debounce処理：指定時間後に検索を実行
    this.debounceTimeout = setTimeout(() => {
      this.performCheck()
    }, this.debounceDelayValue)
  }

  // 重複チェックを実行
  async performCheck() {
    const title = this.titleTarget.value.trim()
    const composer = this.composerTarget.value.trim()
    const arranger = this.arrangerTarget.value.trim()

    if (title === "") {
      this.hideWarning()
      return
    }

    this.abortRequest()

    this.abortController = new AbortController()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("title", title)
      url.searchParams.set("composer", composer)
      url.searchParams.set("arranger", arranger)

      const response = await fetch(url, {
        signal: this.abortController.signal,
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      if (data.duplicate) {
        this.showWarning(data.url)
      } else {
        this.hideWarning()
      }
    } catch (error) {
      // AbortErrorは無視（意図的なキャンセル）
      if (error.name !== "AbortError") {
        this.hideWarning()
      }
    }
  }

  showWarning(url) {
    const message = `<div class="alert alert-warning">
      <div>
        <h2 class="mb-2">類似する曲が見つかりました</h2>
        <a href="${this.escapeHtml(url)}" target="_blank" class="btn btn-sm btn-outline">
          詳細を確認
        </a>
      </div>
    </div>`

    this.warningTarget.innerHTML = message
    this.warningTarget.classList.remove("hidden")
  }

  hideWarning() {
    this.warningTarget.classList.add("hidden")
    this.warningTarget.innerHTML = ""
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clearDebounce() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
      this.debounceTimeout = null
    }
  }

  abortRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }
}
