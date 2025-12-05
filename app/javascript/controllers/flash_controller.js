import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    // 消える処理を開始するまでの時間
    delay: { type: Number, default: 3000 },

    // フェードアウトする時間
    fadeDuration: { type: Number, default: 1000 }
  }

  connect() {
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, this.delayValue)
  }

  disconnect() {
    // タイマーをクリーンアップ
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
    if (this.removeTimeout) {
      clearTimeout(this.removeTimeout)
    }
    // 要素が残っている場合は削除
    if (this.element && this.element.parentNode) {
      this.element.remove()
    }
  }

  hide() {
    // フェードアウトアニメーションを開始
    this.element.style.transition = `opacity ${this.fadeDurationValue}ms`;
    this.element.style.opacity = "0";

    // フェードアウトアニメーション終了後削除
    this.removeTimeout = setTimeout(() => {
      this.element.remove()
    }, this.fadeDurationValue)
  }
}
