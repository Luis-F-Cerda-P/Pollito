import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]
  static values = { open: Boolean }

  connect() {
    if (!this.hasMenuTarget) return

    // Close dropdown when clicking outside
    document.addEventListener('click', this.closeOnClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside.bind(this))
  }

  toggle() {
    this.openValue = !this.openValue
  }

  close() {
    this.openValue = false
  }

  openValueChanged() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle('hidden', !this.openValue)
    }
  }

  closeOnClickOutside(event) {
    if (this.element.contains(event.target)) return
    this.close()
  }
}