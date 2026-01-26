import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["byStage", "chronological", "stageTab", "chronoTab", "closedToggle", "matchItem"]
  static values = {
    storageKey: { type: String, default: "predictions_view_preference" }
  }

  connect() {
    this.loadPreferences()
  }

  loadPreferences() {
    const stored = localStorage.getItem(this.storageKeyValue)
    if (stored) {
      try {
        const prefs = JSON.parse(stored)
        if (prefs.view === "chronological") {
          this.showChronological()
        } else {
          this.showByStage()
        }
        if (prefs.hideClosed && this.hasClosedToggleTarget) {
          this.closedToggleTarget.checked = true
          this.applyClosedFilter(true)
        }
      } catch (e) {
        // Invalid stored data, use defaults
      }
    }
  }

  savePreferences() {
    const prefs = {
      view: this.hasByStageTarget && !this.byStageTarget.classList.contains("hidden") ? "byStage" : "chronological",
      hideClosed: this.hasClosedToggleTarget ? this.closedToggleTarget.checked : false
    }
    localStorage.setItem(this.storageKeyValue, JSON.stringify(prefs))
  }

  showByStage() {
    if (this.hasByStageTarget) {
      this.byStageTarget.classList.remove("hidden")
    }
    if (this.hasChronologicalTarget) {
      this.chronologicalTarget.classList.add("hidden")
    }
    this.updateTabStyles("byStage")
    this.savePreferences()
  }

  showChronological() {
    if (this.hasByStageTarget) {
      this.byStageTarget.classList.add("hidden")
    }
    if (this.hasChronologicalTarget) {
      this.chronologicalTarget.classList.remove("hidden")
    }
    this.updateTabStyles("chronological")
    this.savePreferences()
  }

  updateTabStyles(activeView) {
    const activeClasses = ["bg-indigo-600", "text-white"]
    const inactiveClasses = ["bg-gray-200", "text-gray-700"]

    if (this.hasStageTabTarget) {
      if (activeView === "byStage") {
        this.stageTabTarget.classList.remove(...inactiveClasses)
        this.stageTabTarget.classList.add(...activeClasses)
      } else {
        this.stageTabTarget.classList.remove(...activeClasses)
        this.stageTabTarget.classList.add(...inactiveClasses)
      }
    }

    if (this.hasChronoTabTarget) {
      if (activeView === "chronological") {
        this.chronoTabTarget.classList.remove(...inactiveClasses)
        this.chronoTabTarget.classList.add(...activeClasses)
      } else {
        this.chronoTabTarget.classList.remove(...activeClasses)
        this.chronoTabTarget.classList.add(...inactiveClasses)
      }
    }
  }

  toggleClosed(event) {
    const hideClosed = event.target.checked
    this.applyClosedFilter(hideClosed)
    this.savePreferences()
  }

  applyClosedFilter(hideClosed) {
    this.matchItemTargets.forEach(item => {
      const isClosed = item.dataset.matchStatus !== "bets_open"
      if (hideClosed && isClosed) {
        item.classList.add("hidden")
      } else {
        item.classList.remove("hidden")
      }
    })
  }
}
