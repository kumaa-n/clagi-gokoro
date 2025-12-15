import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  static classes = {
    active: ["bg-primary", "text-white", "shadow-md"],
    inactive: ["bg-white", "text-neutral/60", "border", "border-base-200"],
    badgeActive: ["bg-white", "text-primary"],
    badgeInactive: ["bg-base-100", "text-primary"]
  }

  connect() {
    // 最初のタブをアクティブにする
    this.showTab(0)
  }

  switch(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    const {active, inactive, badgeActive, badgeInactive} = this.constructor.classes

    this.tabTargets.forEach((tab, i) => {
      const badge = tab.querySelector(".badge")
      const isActive = i === index

      // タブのスタイル切り替え
      tab.classList.remove(...active, ...inactive)
      tab.classList.add(...(isActive ? active : inactive))

      // バッジのスタイル切り替え
      if (badge) {
        badge.classList.remove(...badgeActive, ...badgeInactive)
        badge.classList.add(...(isActive ? badgeActive : badgeInactive))
      }
    })

    // 対応するパネルを表示
    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }
}
