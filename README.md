# Pollito - World Cup Betting Pool

A modern, interactive web application for creating and managing World Cup betting pools among friends and colleagues.

## Overview

Pollito is a Ruby on Rails 8 application that enables users to:
- Create private betting pools for the 2026 FIFA World Cup
- Make predictions on matches before they start
- Track scores and compete on leaderboards
- Manage multiple pools with different groups of people

## Tech Stack

**Backend:**
- Ruby 3.3.5 with Rails 8.0.3
- PostgreSQL database with SQLite for development
- Solid Suite (Cache, Queue, Cable) for background services
- Authentication with secure password handling

**Frontend:**
- Hotwire (Turbo + Stimulus) for SPA-like experience
- Tailwind CSS for modern, responsive design
- Flowbite UI components
- Import Maps for JavaScript management

**Infrastructure:**
- Docker containerization
- Kamal for zero-downtime deployments
- Puma with Thruster for HTTP acceleration
- Let's Encrypt SSL auto-certification

## Key Features

### Core Models
- **Users**: Secure authentication with session management
- **Events**: Tournament management (World Cup 2026)
- **Teams**: National team information
- **Matches**: Complete match schedule with scores
- **Betting Pools**: Private prediction groups
- **Predictions**: User forecasts with scoring system

### Scoring System
- **Exact Score**: 3 points
- **Correct Outcome**: 1 point
- Real-time leaderboard updates
- Pool-specific rankings

### Caching Strategy
- Fragment caching for leaderboards
- Russian doll caching for match results
- Low-level cache for expensive calculations
- Optimized for high concurrent traffic

## Getting Started

### Prerequisites
- Ruby 3.3.5+
- Node.js 18+
- PostgreSQL 14+ (production)

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-username/pollito.git
cd pollito
```

2. Install dependencies
```bash
bundle install
npm install
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
bin/rails server              # Start Rails server
bin/rails console             # Rails console
bin/rails test               # Run test suite
bin/rubocop                  # Code linting
bin/brakeman                 # Security scanning
bin/rails tailwindcss:watch  # Compile CSS
```

## Testing

Run the complete test suite:
```bash
bin/rails test
```

Run system tests:
```bash
bin/rails test:system
```

## Deployment

Pollito is designed for easy deployment with Kamal:

```bash
bin/kamal deploy              # Deploy to production
bin/kamal app logs           # View application logs
bin/kamal app console        # Access production console
```

## Code Quality

- **RuboCop**: Enforces Ruby style guide
- **Brakeman**: Security vulnerability scanning  
- **Rails Testing**: Comprehensive test coverage
- **Code Review**: Pull-based development workflow

## Performance

- Optimized for 50+ concurrent users
- Multi-level caching strategy
- Efficient database queries
- Background job processing
- HTTP acceleration with Thruster

## Security

- Secure password hashing with bcrypt
- CSRF protection
- Parameter validation
- SQL injection prevention
- Regular security scanning

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is licensed under the MIT License.

---

# Pollito - Quiniela del Mundial

Una aplicación web moderna e interactiva para crear y gestionar quinielas del Mundial entre amigos y colegas.

## Resumen

Pollito es una aplicación Ruby on Rails 8 que permite a los usuarios:
- Crear quinielas privadas para el Mundial FIFA 2026
- Hacer predicciones sobre partidos antes de que comiencen
- Seguir puntajes y competir en tablas de posiciones
- Gestionar múltiples quinielas con diferentes grupos

## Stack Tecnológico

**Backend:**
- Ruby 3.3.5 con Rails 8.0.3
- PostgreSQL con SQLite para desarrollo
- Solid Suite (Cache, Queue, Cable) para servicios en background
- Autenticación con manejo seguro de contraseñas

**Frontend:**
- Hotwire (Turbo + Stimulus) para experiencia tipo SPA
- Tailwind CSS para diseño moderno y responsivo
- Componentes UI Flowbite
- Import Maps para gestión de JavaScript

**Infraestructura:**
- Contenedores Docker
- Kamal para despliegues sin downtime
- Puma con Thruster para aceleración HTTP
- Auto-certificación SSL Let's Encrypt

## Características Principales

### Modelos Centrales
- **Usuarios**: Autenticación segura con gestión de sesiones
- **Eventos**: Gestión de torneos (Mundial 2026)
- **Equipos**: Información de selecciones nacionales
- **Partidos**: Calendario completo con resultados
- **Quinielas**: Grupos privados de predicciones
- **Predicciones**: Pronósticos de usuarios con sistema de puntuación

### Sistema de Puntuación
- **Resultado Exacto**: 3 puntos
- **Resultado Correcto**: 1 punto
- Actualizaciones en tiempo real de tablas
- Rankings específicos por quiniela

### Estrategia de Caching
- Fragment caching para tablas de posiciones
- Russian doll caching para resultados de partidos
- Low-level cache para cálculos costosos
- Optimizado para alto tráfico concurrente

## Comenzar

### Prerrequisitos
- Ruby 3.3.5+
- Node.js 18+
- PostgreSQL 14+ (producción)

### Instalación

1. Clonar el repositorio
```bash
git clone https://github.com/your-username/pollito.git
cd pollito
```

2. Instalar dependencias
```bash
bundle install
npm install
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
bin/rails server              # Iniciar servidor Rails
bin/rails console             # Consola Rails
bin/rails test               # Ejecutar suite de pruebas
bin/rubocop                  # Linting de código
bin/brakeman                 # Escaneo de seguridad
bin/rails tailwindcss:watch  # Compilar CSS
```

## Pruebas

Ejecutar suite completa de pruebas:
```bash
bin/rails test
```

Ejecutar pruebas de sistema:
```bash
bin/rails test:system
```

## Despliegue

Pollito está diseñado para fácil despliegue con Kamal:

```bash
bin/kamal deploy              # Desplegar a producción
bin/kamal app logs           # Ver logs de aplicación
bin/kamal app console        # Acceder a consola de producción
```

## Calidad de Código

- **RuboCop**: Aplica guía de estilo Ruby
- **Brakeman**: Escaneo de vulnerabilidades de seguridad
- **Pruebas Rails**: Cobertura de pruebas comprehensiva
- **Code Review**: Flujo de desarrollo basado en pull requests

## Rendimiento

- Optimizado para 50+ usuarios concurrentes
- Estrategia multinivel de caching
- Consultas de base de datos eficientes
- Procesamiento de trabajos en background
- Aceleración HTTP con Thruster

## Seguridad

- Hash seguro de contraseñas con bcrypt
- Protección CSRF
- Validación de parámetros
- Prevención de inyección SQL
- Escaneo de seguridad regular

## Contribuir

1. Fork del repositorio
2. Crear rama de feature
3. Realizar cambios
4. Ejecutar pruebas y linting
5. Submit pull request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT.