import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cascading-select"
export default class extends Controller {
  static targets = ["parent", "child"]
  static values = { options: Object }

  connect() {
    // Initialize child options based on current parent selection
    this.filter()
  }

  filter() {
    const parentValue = this.parentTarget.value
    const childSelect = this.childTarget
    const currentChildValue = childSelect.dataset.selectedValue || childSelect.value

    // Clear current options
    childSelect.innerHTML = '<option value="">Select stage</option>'

    if (!parentValue) {
      return
    }

    // Get stages for selected event
    const stages = this.optionsValue[parentValue] || []

    // Add new options
    stages.forEach(stage => {
      const option = document.createElement("option")
      option.value = stage.id
      option.textContent = stage.name
      if (String(stage.id) === String(currentChildValue)) {
        option.selected = true
      }
      childSelect.appendChild(option)
    })
  }
}
