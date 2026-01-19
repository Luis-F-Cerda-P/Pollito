import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["poolSelect", "matchSelect"]

  connect() {
    // Add event listener if not using data-action
    if (this.poolSelectTarget) {
      this.poolSelectTarget.addEventListener('change', () => this.updateMatches())
    }
  }

  updateMatches() {
    const poolId = this.poolSelectTarget.value
    
    if (!poolId) {
      this.hideMatches()
      return
    }

    fetch(`/betting_pools/${poolId}/matches.json`)
      .then(response => response.json())
      .then(data => {
        this.updateMatchOptions(data)
        this.showMatches()
      })
      .catch(error => {
        console.error('Error loading matches:', error)
        this.hideMatches()
      })
  }

  updateMatchOptions(matches) {
    this.matchSelectTarget.innerHTML = '<option value="">Select a match</option>'
    
    matches.forEach(match => {
      const option = document.createElement('option')
      option.value = match.id
      option.textContent = `${match.team1_name || 'TBD'} vs ${match.team2_name || 'TBD'} - ${match.match_date}`
      this.matchSelectTarget.appendChild(option)
    })
  }

  showMatches() {
    document.getElementById('matches-section').classList.remove('hidden')
    document.getElementById('prediction-scores').classList.remove('hidden')
  }

  hideMatches() {
    document.getElementById('matches-section').classList.add('hidden')
    document.getElementById('prediction-scores').classList.add('hidden')
  }
}