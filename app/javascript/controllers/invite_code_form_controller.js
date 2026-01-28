import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  submit() {
    const code = this.inputTarget.value.trim().toLowerCase()

    if (code.length !== 8) {
      this.showError("Invite code must be 8 characters")
      return
    }

    if (!/^[a-z0-9]+$/.test(code)) {
      this.showError("Invite code can only contain letters and numbers")
      return
    }

    this.hideError()
    window.location.href = `/join/${code}`
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }
}
