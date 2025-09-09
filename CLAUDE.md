# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Profitry is an investment portfolio cost basis calculator built with Elixir and Phoenix LiveView. It helps track profit and loss by accounting for stock purchases/sales and options premiums.

## Development Commands

### Essential Commands
- `mix setup` - Install dependencies and set up the database
- `mix test` - Run tests (includes database setup)
- `mix check` - Run static analysis with Dialyzer
- `mix phx.server` - Start development server
- `mix assets.build` - Build frontend assets
- `mix assets.deploy` - Build and minify assets for production

### Database Operations
- `mix ecto.setup` - Create and migrate database, run seeds
- `mix ecto.reset` - Drop and recreate database
- `mix ecto.migrate` - Run migrations
- `mix ecto.rollback` - Rollback migrations

### Deployment
- `mix deploy` - Run deployment script
- `mix release` - Build release for production

## Architecture

### Core Contexts
- **Profitry.Investment** - Portfolio management, positions, and cost basis calculations
- **Profitry.Exchanges** - Real-time quote fetching and broadcasting (Finnhub integration)
- **Profitry.Import** - Import functionality for broker statements (IBKR parser)
- **Profitry.Accounts** - User authentication and management

### Key Components
- **PositionReport** (`lib/profitry/investment/schema/position_report.ex`) - Core position reporting with cost basis calculations
- **Exchanges.Supervisor** (`lib/profitry/exchanges/supervisor.ex`) - Manages exchange clients and quote polling
- **Import.Trades** (`lib/profitry/import/trades.ex`) - Trade import and processing
- **LiveViews** - Real-time UI components for portfolio management

### Real-time Features
- Phoenix PubSub for real-time quote updates
- PollServer architecture for exchange data fetching
- LiveView components for reactive UI updates

### Database Schema
- PostgreSQL with Ecto
- Key schemas: positions, trades, options, users
- Migration files in `priv/repo/migrations/`

### Testing
- Test files mirror lib structure in `test/` directory
- Uses ExUnit for testing
- Database tests run with sandbox mode

### Frontend
- Phoenix LiveView with HEEx templates
- Tailwind CSS for styling
- Heroicons for UI icons
- ESBuild and Tailwind for asset compilation

### External Integrations
- **Finnhub API** - Real-time stock quotes
- **Interactive Brokers** - Trade statement parsing
- **PostgreSQL** - Primary database

### Configuration
- Environment-specific configs in `config/`
- Docker setup in `docker/docker-compose.yml`
- Deployment scripts in `deploy/`