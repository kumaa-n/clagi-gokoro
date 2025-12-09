import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = { open: Boolean }

  connect() {
    if (!this.openValue) return

    // Turboがこの画面をキャッシュする前にダイアログを削除
    document.addEventListener("turbo:before-cache", this.beforeCache)

    // DOMの描画完了後にモーダルを開く
    requestAnimationFrame(this.show.bind(this))
  }

  disconnect() {
    // 別ページに移動した時にイベントを解除
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  beforeCache = () => {
    // Turboが画面をキャッシュする前にモーダル要素を削除
    this.element.remove()
  }

  show() {
    const dialog = this.dialogTarget
    if (!dialog.open) dialog.showModal()
  }
}
