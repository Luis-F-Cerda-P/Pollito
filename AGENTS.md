# AGENTS.md

This file contains guidelines and commands for AI agents working in the Pollia Rails application.

## Project Overview

Pollia is a **Ruby on Rails 8.0.3** application using:
- Ruby 3.3.5 with PostgreSQL database
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Tailwind CSS for styling with Import Maps for JavaScript
- Solid suite (Cache, Queue, Cable) for background services
- Kamal for Docker-based deployment
- Puma with Thruster for HTTP acceleration

## Development Commands

### Server & Development
```bash
bin/rails server              # Start Rails development server
bin/dev                       # Start development with Procfile.dev
bin/rails tailwindcss:watch   # Watch and compile Tailwind CSS
bin/rails console             # Rails console
bin/rails dbconsole           # Database console
```

### Code Quality & Security
```bash
bin/rubocop                   # Ruby code linting (Omakase style)
bin/brakeman                  # Security vulnerability scanning
bin/importmap audit          # JavaScript dependency security audit
```

### Testing Commands
```bash
bin/rails test               # Run all unit tests
bin/rails test path/to/file  # Run single test file
bin/rails test:system        # Run system tests
bin/rails db:test:prepare    # Prepare test database
```

### Deployment
```bash
bin/kamal deploy             # Deploy to production
bin/thrust                   # HTTP acceleration commands
```

## Code Style Guidelines

### Ruby/Rails Style
- **Omakase Ruby styling** via `rubocop-rails-omakase`
- 2-space indentation
- Standard Rails naming conventions:
  - PascalCase for classes/modules
  - snake_case for methods/files
  - SCREAMING_SNAKE_CASE for constants
- Controllers inherit from `ApplicationController`
- Models inherit from `ApplicationRecord`
- Use modern Ruby syntax (safe navigation, endless methods where appropriate)

### Import Organization
```ruby
# Rails core first
require "rails/all"

# Then gems
require "devise"
require "sidekiq"

# Then relative requires
require_relative "concerns/authable"
```

### Method Definitions
- Use def syntax for public methods
- Use private/protected sections appropriately
- Prefer method delegation over simple wrappers

### Error Handling
- Use Rails standard error handling patterns
- Implement proper exception handling in controllers
- Use `begin..rescue` blocks sparingly
- Leverage Active Record validations for model errors

### Database Patterns
- Use Rails migrations for schema changes
- Follow Rails naming conventions for tables/columns
- Use indexes for frequently queried columns
- Consider database constraints for data integrity

## Frontend Guidelines

### JavaScript (Stimulus)
- Use ES6 modules with Import Maps
- Stimulus controllers for interactive components
- Keep JavaScript unobtrusive and progressive
- Use Turbo for navigation and form submissions

### CSS (Tailwind)
- Utility-first approach with Tailwind CSS
- Component-based organization encouraged
- Use responsive prefixes (`sm:`, `md:`, `lg:`)
- Prefer semantic HTML with Tailwind classes

### File Organization
```
app/
├── controllers/         # Request handlers
├── models/            # Data models
├── views/             # Templates
├── javascript/
│   ├── controllers/   # Stimulus controllers
│   └── application.js # Main entry point
├── assets/stylesheets/ # CSS files
└── jobs/              # Background jobs
```

## Testing Guidelines

### Test Structure
- Unit tests in `test/models/`, `test/controllers/`
- System tests in `test/system/`
- Integration tests in `test/integration/`
- Use Rails built-in testing framework

### Test Patterns
```ruby
class ExampleTest < ActiveSupport::TestCase
  test "should do something" do
    # Arrange
    object = create(:example)
    
    # Act
    result = object.perform_action
    
    # Assert
    assert_equal expected, result
  end
end
```

### Fixtures & Factories
- Use YAML fixtures in `test/fixtures/`
- Consider FactoryBot for complex object creation
- Clean test data between runs

## Security Best Practices

- Run `bin/brakeman` regularly for security scanning
- Use Rails built-in CSRF protection
- Implement proper authentication/authorization
- Validate all user inputs
- Use parameterized queries to prevent SQL injection
- Keep dependencies updated with `bundle update`

## Performance Considerations

- Use Rails caching mechanisms
- Optimize database queries (N+1 prevention)
- Use background jobs for long-running tasks
- Leverage Solid suite for scalable services
- Monitor asset compilation and loading

## Deployment Notes

- Application containerized with Docker
- Kamal handles zero-downtime deployments
- SSL auto-certification via Let's Encrypt
- Use environment variables for configuration
- Persistent storage volumes for data

## Common Patterns

### Controllers
```ruby
class ExamplesController < ApplicationController
  before_action :set_example, only: [:show, :edit, :update, :destroy]
  
  def index
    @examples = Example.all
  end
  
  private
  
  def set_example
    @example = Example.find(params[:id])
  end
end
```

### Models
```ruby
class Example < ApplicationRecord
  validates :name, presence: true
  
  has_many :related_items, dependent: :destroy
  
  def some_method
    # implementation
  end
end
```

### Stimulus Controllers
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  
  connect() {
    // initialization
  }
  
  someAction() {
    // handle interaction
  }
}
```

## Important Notes

- Always run `bin/rubocop` before committing
- Test thoroughly with `bin/rails test`
- Use modern browser features (webp, CSS nesting, etc.)
- Follow Rails conventions over configuration
- Keep the codebase clean and maintainable