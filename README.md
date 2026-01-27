# Pollito - Betting Pool Platform

A modern, interactive web application for creating and managing betting pools for major events like the FIFA World Cup and the Academy Awards.

## Overview

Pollito is a Ruby on Rails 8 application that enables users to:
- Create public or private betting pools for major events
- Make predictions on matches and award categories
- Track scores and compete on leaderboards
- Manage multiple pools with different groups of people

### Supported Events

- **FIFA World Cup 2026** - Score-based predictions for football matches
- **Academy Awards (Oscars)** - Winner predictions for award categories

## Tech Stack

**Backend:**
- Ruby 3.3.5 with Rails 8.1.2
- SQLite for all environments (dev/test/prod)
- Solid Suite (Cache, Queue, Cable) for background services
- Passwordless OTP authentication (6-digit codes via email)

**Frontend:**
- Hotwire (Turbo + Stimulus) for SPA-like experience
- Tailwind CSS for modern, responsive design
- Flowbite UI components
- Import Maps for JavaScript (no Node.js build step)

**Infrastructure:**
- Docker containerization
- Kamal for zero-downtime deployments
- Puma with Thruster for HTTP acceleration

## Key Features

### Match Types
- **One-on-One** (Sports): Predict scores for two-team matches
- **Multi-Nominee** (Awards): Pick winners from multiple nominees

### Scoring System
- **Exact Score Match**: 2 points per correct score (sports)
- **Correct Outcome** (win/draw): 3 points (sports)
- **Correct Winner**: 5 points (awards)
- Real-time leaderboard updates
- Pool-specific rankings

### Match Status Lifecycle
1. `unset` - Participants not yet determined
2. `bets_open` - Predictions allowed
3. `bets_closed` - Stage deadline reached (12h before first match)
4. `in_progress` - Match underway
5. `finished` - Match complete, scores calculated

### Authentication
- Passwordless email authentication with OTP codes
- 6-digit codes sent via email, valid for 15 minutes
- 5-attempt limit for security
- Admin users can also use password authentication

## Getting Started

### Prerequisites
- Ruby 3.3.5+

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-username/pollito.git
cd pollito
```

2. Install dependencies
```bash
bundle install
```

3. Setup database
```bash
bin/rails db:create db:migrate db:seed
```

4. Start development server
```bash
bin/dev
```

### Development Commands

```bash
bin/dev                       # Start all services (Rails + Tailwind watcher)
bin/rails server              # Rails server only
bin/rails console             # Interactive Rails console
bin/rails test                # Run test suite
bin/rails test:system         # Run system tests
bin/rubocop                   # Ruby linting
bin/rubocop -a                # Auto-fix style issues
bin/brakeman                  # Security vulnerability scan
bin/rails tailwindcss:watch   # Compile CSS in watch mode
```

## Data Import

### FIFA World Cup
Import tournament data from FIFA JSON:
```bash
# Via admin interface at /admin/tournaments
# Or via Rails console:
FifaTournamentImporter.new(json_data).import!
```

### Academy Awards
Import Oscar nominations from HTML:
```bash
# Via Rails console:
OscarNominationsImporter.new(html_content).import!
```

## Testing

Run the complete test suite:
```bash
bin/rails test
```

Run system tests (Capybara + Selenium):
```bash
bin/rails test:system
```

## Deployment

Pollito is designed for deployment with Kamal:

```bash
bin/kamal deploy              # Deploy to production
bin/kamal app logs            # View application logs
bin/kamal app console         # Access production console
```

## Code Quality

- **RuboCop**: Enforces Rails Omakase style guide
- **Brakeman**: Security vulnerability scanning
- **Import Map Audit**: JavaScript dependency security
- **CI/CD**: GitHub Actions for automated testing

## Security

- Bcrypt password hashing (admin accounts)
- OTP codes hashed with bcrypt
- CSRF protection
- Session-based authentication with secure cookies
- SQL injection prevention via ActiveRecord

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is licensed under the MIT License.

---

# Pollito - Plataforma de Quinielas

Una aplicacion web moderna e interactiva para crear y gestionar quinielas de eventos importantes como el Mundial de Futbol FIFA y los Premios de la Academia.

## Resumen

Pollito es una aplicacion Ruby on Rails 8 que permite a los usuarios:
- Crear quinielas publicas o privadas para eventos importantes
- Hacer predicciones sobre partidos y categorias de premios
- Seguir puntajes y competir en tablas de posiciones
- Gestionar multiples quinielas con diferentes grupos

### Eventos Soportados

- **Mundial FIFA 2026** - Predicciones de marcadores para partidos de futbol
- **Premios de la Academia (Oscar)** - Predicciones de ganadores por categoria

## Stack Tecnologico

**Backend:**
- Ruby 3.3.5 con Rails 8.1.2
- SQLite para todos los ambientes (dev/test/prod)
- Solid Suite (Cache, Queue, Cable) para servicios en background
- Autenticacion sin contrasena con OTP (codigos de 6 digitos por email)

**Frontend:**
- Hotwire (Turbo + Stimulus) para experiencia tipo SPA
- Tailwind CSS para diseno moderno y responsivo
- Componentes UI Flowbite
- Import Maps para JavaScript (sin paso de compilacion Node.js)

**Infraestructura:**
- Contenedores Docker
- Kamal para despliegues sin downtime
- Puma con Thruster para aceleracion HTTP

## Caracteristicas Principales

### Tipos de Partidos/Competencias
- **Uno contra Uno** (Deportes): Predecir marcadores para partidos de dos equipos
- **Multi-Nominado** (Premios): Elegir ganadores entre multiples nominados

### Sistema de Puntuacion
- **Marcador Exacto**: 2 puntos por marcador correcto (deportes)
- **Resultado Correcto** (victoria/empate): 3 puntos (deportes)
- **Ganador Correcto**: 5 puntos (premios)
- Actualizaciones en tiempo real de tablas
- Rankings especificos por quiniela

### Ciclo de Estado de Partidos
1. `unset` - Participantes aun no determinados
2. `bets_open` - Predicciones permitidas
3. `bets_closed` - Fecha limite de etapa alcanzada (12h antes del primer partido)
4. `in_progress` - Partido en curso
5. `finished` - Partido completado, puntajes calculados

### Autenticacion
- Autenticacion por email sin contrasena con codigos OTP
- Codigos de 6 digitos enviados por email, validos por 15 minutos
- Limite de 5 intentos por seguridad
- Usuarios admin tambien pueden usar contrasena

## Comenzar

### Prerrequisitos
- Ruby 3.3.5+

### Instalacion

1. Clonar el repositorio
```bash
git clone https://github.com/your-username/pollito.git
cd pollito
```

2. Instalar dependencias
```bash
bundle install
```

3. Configurar base de datos
```bash
bin/rails db:create db:migrate db:seed
```

4. Iniciar servidor de desarrollo
```bash
bin/dev
```

### Comandos de Desarrollo

```bash
bin/dev                       # Iniciar todos los servicios (Rails + Tailwind watcher)
bin/rails server              # Solo servidor Rails
bin/rails console             # Consola interactiva Rails
bin/rails test                # Ejecutar suite de pruebas
bin/rails test:system         # Ejecutar pruebas de sistema
bin/rubocop                   # Linting de Ruby
bin/rubocop -a                # Auto-corregir problemas de estilo
bin/brakeman                  # Escaneo de vulnerabilidades
bin/rails tailwindcss:watch   # Compilar CSS en modo watch
```

## Importacion de Datos

### Mundial FIFA
Importar datos del torneo desde JSON de FIFA:
```bash
# Via interfaz admin en /admin/tournaments
# O via consola Rails:
FifaTournamentImporter.new(json_data).import!
```

### Premios de la Academia
Importar nominaciones del Oscar desde HTML:
```bash
# Via consola Rails:
OscarNominationsImporter.new(html_content).import!
```

## Pruebas

Ejecutar suite completa de pruebas:
```bash
bin/rails test
```

Ejecutar pruebas de sistema (Capybara + Selenium):
```bash
bin/rails test:system
```

## Despliegue

Pollito esta disenado para despliegue con Kamal:

```bash
bin/kamal deploy              # Desplegar a produccion
bin/kamal app logs            # Ver logs de aplicacion
bin/kamal app console         # Acceder a consola de produccion
```

## Calidad de Codigo

- **RuboCop**: Aplica guia de estilo Rails Omakase
- **Brakeman**: Escaneo de vulnerabilidades de seguridad
- **Import Map Audit**: Seguridad de dependencias JavaScript
- **CI/CD**: GitHub Actions para pruebas automatizadas

## Seguridad

- Hash de contrasenas con bcrypt (cuentas admin)
- Codigos OTP hasheados con bcrypt
- Proteccion CSRF
- Autenticacion basada en sesiones con cookies seguras
- Prevencion de inyeccion SQL via ActiveRecord

## Contribuir

1. Fork del repositorio
2. Crear rama de feature
3. Realizar cambios
4. Ejecutar pruebas y linting
5. Submit pull request

## Licencia

Este proyecto esta licenciado bajo la Licencia MIT.
