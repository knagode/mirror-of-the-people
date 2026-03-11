import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["segment", "panel", "panelText", "likeBtn", "dislikeBtn", "panelStats"]
  static values = {
    url: String,
    scores: Array,
    myReactions: Object
  }

  connect() {
    this.selectedIndex = null
    this.applyHeatmap()
    this.outsideClickHandler = (e) => {
      if (this.selectedIndex === null) return
      if (e.target.closest("[data-article-heatmap-target='segment']")) return
      this.deselect()
    }
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  deselect() {
    this.selectedIndex = null
    this.segmentTargets.forEach(s => s.classList.remove("segment-selected"))
    this.panelTarget.classList.add("hidden")
  }

  select(event) {
    const el = event.currentTarget
    const index = parseInt(el.dataset.index)

    this.selectedIndex = index
    this.segmentTargets.forEach(s => s.classList.remove("segment-selected"))
    el.classList.add("segment-selected")

    this.panelTextTarget.textContent = el.textContent
    this.panelTarget.classList.remove("hidden")
    this.likeBtnTarget.disabled = false
    this.dislikeBtnTarget.disabled = false

    this.updateButtonStates()
    this.updatePanelStats()
  }

  like() {
    this.react(1)
  }

  dislike() {
    this.react(-1)
  }

  async react(value) {
    if (this.selectedIndex === null) return

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({ segment_index: this.selectedIndex, value: value })
    })

    const data = await response.json()
    this.scoresValue = data.scores
    this.myReactionsValue = data.my_reactions
    this.applyHeatmap()
    this.deselect()
  }

  applyHeatmap() {
    this.segmentTargets.forEach((el, i) => {
      const score = this.scoresValue[i]
      if (!score || score.total === 0) {
        el.style.borderRightWidth = ""
        el.style.borderRightColor = ""
        el.dataset.heatLabel = ""
        return
      }

      const net = (score.likes - score.dislikes) / score.total
      const width = Math.min(Math.round(Math.abs(net) * 6 + 2), 8)
      el.style.borderRightWidth = `${width}px`
      el.style.borderRightColor = this.heatColor(net)
      el.dataset.heatLabel = this.heatLabel(net)
      el.title = `${score.likes} všeč, ${score.dislikes} ni všeč`
    })
  }

  updateButtonStates() {
    if (this.selectedIndex === null) return
    const myValue = this.myReactionsValue[this.selectedIndex]

    this.likeBtnTarget.classList.toggle("reaction-active-like", myValue === 1)
    this.dislikeBtnTarget.classList.toggle("reaction-active-dislike", myValue === -1)
  }

  updatePanelStats() {
    if (this.selectedIndex === null) return
    const score = this.scoresValue[this.selectedIndex]
    if (!score) return

    this.panelStatsTarget.innerHTML = `
      <span>${score.likes} všeč</span>
      <span>${score.dislikes} ni všeč</span>
      <span>${score.total} skupaj</span>
    `
  }

  heatColor(score) {
    if (score >= 0.75) return "#16a34a"
    if (score >= 0.4) return "#65a30d"
    if (score >= 0.1) return "#ca8a04"
    if (score > -0.1) return "#94a3b8"
    if (score > -0.4) return "#ea580c"
    return "#dc2626"
  }

  heatLabel(score) {
    if (score >= 0.75) return "zelo priljubljeno"
    if (score >= 0.4) return "pretežno všečno"
    if (score >= 0.1) return "rahlo pozitivno"
    if (score > -0.1) return "nevtralno"
    if (score > -0.4) return "deljeno"
    return "pretežno nevšečno"
  }
}
