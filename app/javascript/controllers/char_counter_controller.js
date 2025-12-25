import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = {
    min: Number,  // 最小文字数
    max: Number,  // 最大文字数
    excludeLineBreaks: {  // 改行を除外するか
      type: Boolean,
      default: false
    }
  }

  connect() {
    this.touched = false  // フィールドに触れたかどうか
    this.updateCount()
  }

  // フィールドがフォーカスされたときに触れたフラグを立てる
  markAsTouched() {
    this.touched = true
    this.updateCount()
  }

  updateCount() {
    const text = this.inputTarget.value
    const count = this.countCharacters(text)

    this.counterTarget.textContent = count

    this.updateColor(count)
  }

  updateColor(count) {
    if (this.isOutOfRange(count)) {
      this.counterTarget.classList.add('text-error')
      this.counterTarget.classList.remove('text-neutral/60')
    } else {
      this.counterTarget.classList.remove('text-error')
      this.counterTarget.classList.add('text-neutral/60')
    }
  }

  isOutOfRange(count) {
    if (this.hasMinValue && count < this.minValue) {
      // 未入力の初期状態は赤くせず、触れたら赤くする
      if (!this.touched && count === 0) {
        return false
      }

      return true
    }

    if (this.hasMaxValue && count > this.maxValue) {
      return true
    }

    return false
  }

  countCharacters(text) {
    if (this.excludeLineBreaksValue) {
      // 改行を除いた文字数をカウント
      return text.replace(/[\r\n]+/g, '').length
    } else {
      return text.length
    }
  }
}
