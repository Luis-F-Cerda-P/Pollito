import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    // Add mobile menu functionality
  }

  toggle() {
    this.menuTarget.classList.toggle('hidden')
  }
}