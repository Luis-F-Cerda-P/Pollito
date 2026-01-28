import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "scoreInput", "loading", "status"]
  static values = {
    matchStatus: String,
    debounceMs: { type: Number, default: 500 },
    submitDelayMs: { type: Number, default: 750 }
  }

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  onInput(event) {
    const input = event.target

    // Validate score is 0-9
    let value = parseInt(input.value, 10)
    if (isNaN(value) || value < 0) {
      input.value = ""
    } else if (value > 9) {
      input.value = 9
    }

    // Check if both scores are filled
    if (this.bothScoresFilled()) {
      this.debouncedSubmit()
    }
  }

  bothScoresFilled() {
    return this.scoreInputTargets.every(input => {
      const value = input.value.trim()
      return value !== "" && !isNaN(parseInt(value, 10))
    })
  }

  debouncedSubmit() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      this.submit()
    }, this.debounceValue)
  }

  submit() {
    if (!this.hasFormTarget) return
    if (this.matchStatusValue !== "bets_open") return

    this.showLoading()

    // Delay submission so spinner is visible for a meaningful duration
    // When Turbo response arrives, it replaces the element with fresh HTML
    // where the spinner is hidden by default
    setTimeout(() => {
      this.formTarget.requestSubmit()
    }, this.submitDelayMsValue)
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden")
    }
  }

  showSuccess() {
    this.hideLoading()
    if (this.hasStatusTarget) {
      this.statusTarget.classList.remove("hidden")
      this.statusTarget.textContent = "Saved"
      this.statusTarget.classList.remove("text-red-600", "bg-red-100")
      this.statusTarget.classList.add("text-green-600", "bg-green-100")
    }
  }

  showError(message = "Error saving") {
    this.hideLoading()
    if (this.hasStatusTarget) {
      this.statusTarget.classList.remove("hidden")
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove("text-green-600", "bg-green-100")
      this.statusTarget.classList.add("text-red-600", "bg-red-100")
    }
  }
}
