# Boxes4 Project - Quick Start Reference for AI Agents

## Project Overview

**Boxes4** is a web application for managing a hierarchy of containers and their contents. It was originally built to track belongings during a move but can be used for other hierarchical inventory management purposes.

**Purpose**: Track items stored in boxes/containers with hierarchical organization, location tracking, and search capabilities.

## Technology Stack

- **Framework**: Ruby on Rails 4.2.8
- **Ruby Version**: 2.6.6
- **Database**: PostgreSQL
- **Frontend**: Traditional Rails views (server-side rendered) with AJAX/AJAJ
- **CSS Framework**: Bootstrap 3.3.1
- **JavaScript**: jQuery with custom AJAJ framework (RAJ)
- **ORM**: ActiveRecord
- **Key Gems**:
  - `awesome_nested_set` - Hierarchical data structure
  - `audited-activerecord` - Audit trails
  - `bootstrap-sass` - Styling
  - `select2-rails` - Enhanced selects

## Running the Application

### Docker Setup (Required for M1 Mac)

The project uses Ruby 2.6.6 which doesn't compile natively on ARM64 (M1 Mac), so Docker with x86 emulation is required.

**Quick start**: Just run `./script/docker_start.sh` - it handles everything (builds image if needed, starts container).

**How it works**:
- Build script (`docker_build.sh`) builds image with `--platform linux/amd64`
- Asset precompile happens inside container during build (cached if nothing changed)
- Start script (`docker_start.sh`) calls build script, then starts container
- Works with Colima or Docker Desktop

**Container setup**:
- Port mapping: 3000:3000
- Environment variables from `.env` file (must include `DATABASE_URL`)
- Volume mount for live code updates
- Platform: linux/amd64 (for x86 emulation)

**Database**:
- PostgreSQL runs OUTSIDE the Docker container on the host
- Connect via `DATABASE_URL` environment variable
- Format: `postgres://username:password@host.docker.internal:5432/database_name`
- Host uses `host.docker.internal` to access host machine from container

**Access**: http://localhost:3000

## Core Domain Models

### Main Models (in `/app/models/`)

- **Thing** - The central model. Represents containers/boxes and their contents. Uses `awesome_nested_set` for hierarchical structure (parent/children relationships via left/right values).

- **Tag** - Categorization/tags that can be applied to Things.

- **ThingTag** - Join table for Many-to-Many relationship between Things and Tags.

- **Audit** - Change tracking for Things (uses `audited-activerecord`).

- **Noun** - Simple noun model (details TBD).

## Controllers

Located in `/app/controllers/`:

- **ThingsController** - Main CRUD operations for Things
- **TagsController** - Tag management
- **MarkedThingsController** - Selection/bulk operations
- **SystemController** - System-level operations

## UI Structure & Conventions

### Three-Column Layout

1. **Left Column**: Table showing contents of the currently selected container
2. **Middle Column**: Traversable, collapsible tree showing entire database hierarchy. Double-click a node to load it as the parent in the left column.
3. **Right Column**: Search interface with various search options

### Navigation

- Top nav includes: "home" (The World root), selections (checkbox feature), tags, and browser back/forward buttons for mobile fullscreen mode
- Data loads via AJAJ on page load, so back/forward always return current DB state

### JavaScript/AJAX Conventions

**All Ajax calls use RAJ (Rails and AJAJ)**:

- **Ajax links**: Use class name convention `a-*` to denote they're Ajax links
- **Data display elements**: Elements updated by returned JSON use class name convention `d-_*_`
  - This allows all elements on the page with that data class to be updated in a single query
  - Example: All elements with class `d-thing_42` would be updated when thing #42 changes

## Database Operations

### Backup & Restore

Scripts in `/script/`:

- **pg_backup.sh** - Database backup
- **pg_restore.sh** - Database restore
- **dump_database.sh** - Legacy database dump script

### Database Setup

In theory, you can:
1. Create the database
2. Load the schema
3. Boot the app

Note: There are some hard-coded row creations that happen on app load if rows don't exist, but these haven't been tested recently.

## Configuration Files

- **config/database.yml** - Database configuration (uses `DATABASE_URL` environment variable)
- **config/routes.rb** - Routing configuration
- **config/application.rb** - Main app configuration
- **Dockerfile** - Docker image definition
- **Gemfile** - Gem dependencies
- **Procfile** - Process management (likely for Heroku/deployment)

## Project Structure

```
boxes4/
├── app/                    # Main application code
│   ├── assets/            # CSS, JS, images
│   ├── controllers/       # Rails controllers
│   ├── models/            # ActiveRecord models
│   ├── views/             # ERB templates
│   └── helpers/           # View helpers
├── config/                # Configuration files
├── db/                    # Database schema, migrations, seeds
├── docker/                # Docker documentation
│   ├── Dockerize.md      # Docker setup instructions
│   └── Docker Images.md  # Docker image management
├── public/               # Static files
├── script/               # Utility scripts (Docker, DB backup)
│   ├── docker_build.sh
│   ├── docker_start.sh
│   ├── pg_backup.sh
│   └── pg_restore.sh
├── spec/                 # RSpec tests
├── vendor/               # Third-party code (includes RAJ engine)
├── Dockerfile            # Docker image definition
├── Gemfile               # Ruby dependencies
├── Procfile              # Process management
└── Rakefile              # Rake tasks
```

## Development Notes

- The codebase is described as "a bit of a mess" but working
- Eventually planned rewrite: React/SPA frontend + lightweight backend (possibly keeping Rails as REST API)
- Main challenge for rewrite: Finding good ORM for Postgres if moving away from Rails ActiveRecord

## Key Points for AI Agents

1. **Docker is mandatory** on M1 Macs due to Ruby 2.6.6 not compiling on ARM64
2. **Database runs on host**, not in Docker container - connect via `DATABASE_URL` with `host.docker.internal`
3. **RAJ (Rails and AJAJ)** is the custom AJAX/AJAJ framework - look for classes `a-*` (ajax links) and `d-_*_` (data display elements)
4. **Things are hierarchical** using nested set pattern (not simple parent_id)
5. **Three-column UI** with tree navigation, content table, and search
6. **Backup scripts** available in `/script/` for database operations
