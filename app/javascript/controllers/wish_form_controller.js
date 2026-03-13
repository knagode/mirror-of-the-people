import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hint"]

  connect() {
    this.currentLevel = null
    this.typeTimer = null
    this.update()
  }

  update() {
    const text = this.inputTarget.value.trim()
    const length = text.length
    const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0).length

    let level, message, className

    if (length === 0) {
      level = null
      message = ""
      className = "wish-hint"
    } else if (length < 60) {
      level = "short"
      message = "✏️ Vaša želja je precej kratka. Poskusite opisati, zakaj si to želite in kakšne konkretne spremembe pričakujete. Konkretne poredloge bo umetna inteligenca lahko tudi jasno vključila v svoje povzetke in predloge državi."
      className = "wish-hint hint-short"
    } else if (sentences < 3) {
      level = "medium"
      message = "💡 Dobro! Dodajte še kakšen konkreten primer iz vašega življenja — kaj točno ne deluje ali kaj bi moralo biti drugače?"
      className = "wish-hint hint-medium"
    } else {
      level = "good"
      message = "✅ Odlično — vaša želja postaja bolj konkretna. Hvala, ker ste si vzeli čas in delite svoje izkušnje. To nam pomaga, da bolje razumemo vaše potrebe in želje ter da jih lahko upoštevamo pri oblikovanju naših rešitev."
      className = "wish-hint hint-good"
    }

    if (level === this.currentLevel) return

    this.currentLevel = level
    this.hintTarget.className = className
    this.typeText(message)
  }

  typeText(message) {
    if (this.typeTimer) {
      clearTimeout(this.typeTimer)
      this.typeTimer = null
    }

    if (!message) {
      this.hintTarget.innerHTML = ""
      return
    }

    const emoji = message.slice(0, message.indexOf(" ") + 1)
    const rest = message.slice(emoji.length)
    const words = rest.split(/(\s+)/)
    let i = 0

    this.hintTarget.innerHTML = emoji

    const typeNext = () => {
      if (i >= words.length) {
        this.typeTimer = null
        return
      }

      // Dump 1-3 words at a time
      const chunk = Math.floor(Math.random() * 3) + 1
      const end = Math.min(i + chunk, words.length)
      const newWords = words.slice(0, end).join("")
      this.hintTarget.innerHTML = emoji + newWords
      i = end

      // Random delay: short pause or longer "thinking" pause
      const delay = Math.random() < 0.15
        ? 150 + Math.random() * 250  // occasional longer pause
        : 30 + Math.random() * 70    // normal fast typing

      this.typeTimer = setTimeout(typeNext, delay)
    }

    typeNext()
  }
}
