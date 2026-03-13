import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 3000 },
    url: String
  }

  connect() {
    this.timer = setInterval(() => {
      const frame = this.element.closest("turbo-frame")
      if (frame && this.urlValue) {
        frame.src = this.urlValue
      }
    }, this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
