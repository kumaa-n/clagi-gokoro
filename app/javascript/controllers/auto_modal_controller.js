import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    if (!this.openValue) return
    document.addEventListener('turbo:before-cache', this.beforeCache.bind(this))

    requestAnimationFrame(() => {
      this.show()
      this.removePromptParam()
    })
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.beforeCache.bind(this))
  }

  beforeCache() {
    this.element.remove()
  }

  show() {
    this.withDialog(dialog => {
      if (typeof dialog.showModal === "function") {
        if (!dialog.open) dialog.showModal()
      } else {
        dialog.setAttribute("open", "open")
      }
    })
  }

  hide() {
    this.withDialog(dialog => {
      if (dialog.open) {
        dialog.close()
      } else {
        dialog.removeAttribute("open")
      }
    })
  }

  withDialog(callback) {
    const dialog = this.hasDialogTarget ? this.dialogTarget : this.element
    if (!dialog) return
    callback(dialog)
  }

  removePromptParam() {
    if (!this.openValue) return
    if (!("replaceState" in window.history)) return

    const url = new URL(window.location.href)
    if (!url.searchParams.has("review_prompt_song_id")) return

    url.searchParams.delete("review_prompt_song_id")
    window.history.replaceState(window.history.state, document.title, url)
  }
}
