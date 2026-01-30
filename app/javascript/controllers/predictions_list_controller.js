import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["matchContainer", "matchItem", "stageHeader", "stageTab", "chronoTab", "closedToggle", "pendingToggle"]
  static values = { view: { type: String, default: "byStage" } }

  connect() {
    this.loadPreferences()
    this.applyCurrentView()
  }

  loadPreferences() {
    const savedView = localStorage.getItem("predictions_view_preference")
    if (savedView) {
      // Handle backward compatibility with old JSON format
      try {
        const parsed = JSON.parse(savedView)
        if (parsed.view) {
          this.viewValue = parsed.view
          // Migrate to new format
          localStorage.setItem("predictions_view_preference", parsed.view)
          if (parsed.hideClosed !== undefined) {
            localStorage.setItem("predictions_hide_closed", parsed.hideClosed.toString())
          }
        }
      } catch {
        // New string format
        this.viewValue = savedView
      }
    }

    const hideClosed = localStorage.getItem("predictions_hide_closed") === "true"
    if (this.hasClosedToggleTarget) this.closedToggleTarget.checked = hideClosed

    const showPending = localStorage.getItem("predictions_show_pending") === "true"
    if (this.hasPendingToggleTarget) this.pendingToggleTarget.checked = showPending
  }

  showByStage() {
    this.viewValue = "byStage"
    localStorage.setItem("predictions_view_preference", "byStage")
    this.applyCurrentView()
  }

  showChronological() {
    this.viewValue = "chronological"
    localStorage.setItem("predictions_view_preference", "chronological")
    this.applyCurrentView()
  }

  applyCurrentView() {
    this.updateTabStyles()
    this.reorderCards()
    this.updateStageHeaders()
    this.applyClosedFilter()
  }

  reorderCards() {
    this.matchItemTargets.forEach(item => {
      if (this.viewValue === "byStage") {
        // Order by: stage_order * 1000 + stage_match_index
        const stageOrder = parseInt(item.dataset.stageOrder) || 0
        const matchIndex = parseInt(item.dataset.stageMatchIndex) || 0
        item.style.order = stageOrder * 1000 + matchIndex
      } else {
        // Order by chronological index
        item.style.order = parseInt(item.dataset.chronoOrder) || 0
      }
    })
  }

  updateStageHeaders() {
    this.stageHeaderTargets.forEach(header => {
      if (this.viewValue === "byStage") {
        header.classList.remove("hidden")
      } else {
        header.classList.add("hidden")
      }
    })
  }

  updateTabStyles() {
    const activeClasses = ["bg-indigo-600", "text-white"]
    const inactiveClasses = ["bg-gray-200", "text-gray-700", "hover:bg-gray-300"]

    if (this.hasStageTabTarget && this.hasChronoTabTarget) {
      if (this.viewValue === "byStage") {
        this.stageTabTarget.classList.remove(...inactiveClasses)
        this.stageTabTarget.classList.add(...activeClasses)
        this.chronoTabTarget.classList.remove(...activeClasses)
        this.chronoTabTarget.classList.add(...inactiveClasses)
      } else {
        this.stageTabTarget.classList.remove(...activeClasses)
        this.stageTabTarget.classList.add(...inactiveClasses)
        this.chronoTabTarget.classList.remove(...inactiveClasses)
        this.chronoTabTarget.classList.add(...activeClasses)
      }
    }
  }

  toggleClosed() {
    const hideClosed = this.closedToggleTarget.checked
    localStorage.setItem("predictions_hide_closed", hideClosed)
    this.applyFilters()
  }

  togglePending() {
    const showPending = this.pendingToggleTarget.checked
    localStorage.setItem("predictions_show_pending", showPending)
    this.applyFilters()
  }

  applyClosedFilter() {
    this.applyFilters()
  }

  applyFilters() {
    const hideClosed = this.hasClosedToggleTarget && this.closedToggleTarget.checked
    const showPending = this.hasPendingToggleTarget && this.pendingToggleTarget.checked

    this.matchItemTargets.forEach(item => {
      const status = item.dataset.matchStatus
      const hasPrediction = item.dataset.hasPrediction === "true"

      // A match is "open" only if status is exactly "bets_open"
      const isOpen = status === "bets_open"

      // Determine if this item should be hidden
      let shouldHide = false

      // Hide closed matches filter
      if (hideClosed && !isOpen) {
        shouldHide = true
      }

      // Show only pending filter (hide items that already have predictions)
      if (showPending && hasPrediction) {
        shouldHide = true
      }

      if (shouldHide) {
        item.classList.add("hidden")
      } else {
        item.classList.remove("hidden")
      }
    })
  }
}
