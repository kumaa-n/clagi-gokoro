import { Controller } from "@hotwired/stimulus"
import Tagify from "@yaireo/tagify"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    whitelist: Array,
    maxTags: Number
  }

  connect() {
    this.initializeTagify()
  }

  disconnect() {
    if (this.tagify) {
      this.tagify.destroy()
    }
  }

  initializeTagify() {
    // フォーム送信用のhiddenフィールドを取得
    this.hiddenField = this.element.querySelector('input[type="hidden"][name*="tags"]')

    this.tagify = new Tagify(this.inputTarget, {
      whitelist: this.whitelistValue,
      maxTags: this.maxTagsValue,
      enforceWhitelist: true,
      dropdown: {
        enabled: 0,
        maxItems: this.whitelistValue.length,
        closeOnSelect: false,
        highlightFirst: true
      },
      editTags: false
    })

    // タグ変更時にhiddenフィールドを更新
    this.tagify.on("change", () => {
      const tags = this.tagify.value.map(item => item.value)
      if (this.hiddenField) {
        this.hiddenField.value = JSON.stringify(tags)
      }
    })
  }
}
