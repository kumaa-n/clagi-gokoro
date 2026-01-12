import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tag"]

  connect() {
    // タグリンクのクリックイベントを処理
    this.element.querySelectorAll('a.badge').forEach(link => {
      link.addEventListener('click', (event) => {
        event.stopPropagation()
      })
    })
  }
}
