import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.style.transition = "opacity 1.0s";
      this.element.style.opacity = "0";
      setTimeout(() => this.element.remove(), 1000);
    }, 3000);
  }
}
