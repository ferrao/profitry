# Profitry Project Summary

## Project Overview

**Profitry** is an investment portfolio cost basis calculator built with Elixir and Phoenix LiveView. It helps investors understand their profit and loss on each portfolio asset by taking into account not only purchased and sold stocks, but also options premium bought or sold against them. The application provides real-time portfolio tracking, cost basis calculations, and comprehensive reporting capabilities.

### Core Purpose
- Calculate accurate cost basis for investment positions
- Track profit/loss across stocks and options
- Handle complex scenarios including stock splits and ticker changes
- Import trading data from broker statements (currently supports Interactive Brokers)
- Provide real-time portfolio valuation with market data integration

## Technical Stack

### Backend Technologies
- **Elixir 1.18.4** - Functional programming language on Erlang VM
- **Phoenix 1.7.12** - Web framework for Elixir
- **Phoenix LiveView 1.0.1** - Real-time web UI without JavaScript
- **Ecto 3.10** - Database wrapper and query language
- **PostgreSQL 16.2** - Primary database with citext extension for case-insensitive text
- **OTP 28** - Open Telecom Platform for concurrent/ distributed systems

### Frontend Technologies
- **Phoenix LiveView** - Primary UI framework
- **Tailwind CSS 3.3.2** - Utility-first CSS framework
- **ESBuild 0.17.11** - JavaScript bundler
- **Heroicons v2.1.5** - Icon library

### Key Dependencies
- **Finch** - HTTP client for external API calls
- **Swoosh** - Email library for notifications
- **Nimble CSV** - CSV parsing for trade imports
- **Timex** - Date/time manipulation
- **Req** - HTTP client library
- **Jason** - JSON parsing
- **Bcrypt Elixir** - Password hashing

## Architecture Patterns

### Overall Architecture
**Modular Monolith** with clear domain boundaries following Phoenix conventions:

```
lib/profitry/           # Core business logic
├── accounts/           # User management and authentication
├── exchanges/          # Market data integration
├── import/            # Data import from brokers
├── investment/        # Portfolio management core
└── utils/             # Shared utilities

lib/profitry_web/      # Web interface layer
├── components/        # Reusable UI components
├── controllers/       # Traditional HTTP endpoints
├── live/             # LiveView components
└── router.ex         # Route definitions
```

### Domain-Driven Design Elements
- **Contexts**: Separate business domains (Investment, Exchanges, Import, Accounts)
- **Aggregates**: Portfolio → Positions → Orders hierarchy
- **Value Objects**: Quote, Split, TickerChange, Delisting
- **Repositories**: Ecto-based data access patterns

### OTP Supervision Tree
```
Profitry.Supervisor
├── ProfitryWeb.Telemetry
├── Profitry.Repo
├── Phoenix.PubSub
├── Finch (HTTP client)
├── ProfitryWeb.Endpoint
└── Profitry.Exchanges.Supervisor
```

## Core Features

### Portfolio Management
- Create and manage multiple portfolios by broker
- Track positions across different securities
- Support for both stock and options trading
- Real-time position reporting with cost basis calculations

### Trading Data Management
- **Orders**: Buy/sell transactions for stocks and options
- **Positions**: Aggregated holdings by ticker within portfolios
- **Options Support**: Calls, puts, strikes, expirations, premium tracking
- **Corporate Actions**: Stock splits, ticker changes, delistings

### Import Capabilities
- **Interactive Brokers Parser**: CSV activity statement import
- **Trade Processing**: Automatic order creation from broker data
- **Validation**: Data integrity checks and error handling

### Real-time Features
- **Market Data Integration**: Finnhub API for real-time quotes
- **PubSub Messaging**: Live updates across connected clients
- **Exchange Polling**: Configurable market data refresh intervals

### Reporting & Analytics
- **Cost Basis Calculation**: FIFO accounting with adjustments
- **Profit/Loss Reporting**: Realized and unrealized gains
- **Position Reports**: Detailed breakdown including options
- **Portfolio Totals**: Aggregated performance metrics

## Database Schema

### Core Tables
- **users**: User authentication and management
- **portfolios**: Broker-specific portfolio containers
- **positions**: Security holdings within portfolios
- **orders**: Individual buy/sell transactions
- **options**: Option contract details (linked to orders)
- **splits**: Stock split adjustments
- **ticker_changes**: Symbol change tracking
- **delistings**: Security delisting events

### Key Relationships
- Portfolio → has_many → Positions → has_many → Orders
- Orders → has_one → Options (for option trades)
- Case-insensitive unique constraints using PostgreSQL citext

## Development Workflow

### Environment Setup
```bash
# Development dependencies
mix setup                    # Install deps, create DB, migrate, build assets
mix phx.server              # Start development server
mix test                    # Run test suite
mix dialyzer               # Static analysis
```

### Testing Strategy
- **Unit Tests**: Context and schema tests with ExUnit
- **Integration Tests**: LiveView component testing
- **Fixtures**: Test data factories for accounts, investments, and parsers
- **Sandbox**: Database isolation with Ecto.Adapters.SQL.Sandbox

### Code Quality Tools
- **Dialyzer**: Static type analysis
- **Formatter**: Consistent code formatting
- **Usage Rules**: Custom development guidelines and best practices

## Deployment Architecture

### Production Deployment
- **Docker Compose**: PostgreSQL database containerization
- **Elixir Releases**: Self-contained production builds
- **Systemd Service**: Process management and monitoring
- **Nginx**: Reverse proxy configuration
- **Logrotate**: Log management

### Release Process
```bash
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

## Security & Authentication

### User Management
- **Magic Link Authentication**: Passwordless login via email
- **Session Tokens**: Secure session management
- **Email Confirmation**: User verification workflow
- **Registration Control**: Configurable user registration

### Data Protection
- **CSRF Protection**: Cross-site request forgery prevention
- **Secure Headers**: Browser security hardening
- **Session Security**: Encrypted session storage

## External Integrations

### Market Data
- **Finnhub API**: Real-time stock quotes and market data
- **Polling Architecture**: Configurable data refresh intervals
- **Fallback Support**: Dummy client for development/testing

### Email Services
- **Swoosh**: Email abstraction layer
- **Local Adapter**: Development email preview
- **Configurable Adapters**: Production email service integration

## Configuration Management

### Environment-Specific Configs
- **config/config.exs**: Base configuration
- **config/dev.exs**: Development settings
- **config/prod.exs**: Production optimizations
- **config/runtime.exs**: Runtime environment variables

### Key Configuration
- Database connection settings
- External API keys and endpoints
- Feature flags (registration, exchange polling)
- Asset pipeline configuration

## Performance Considerations

### Database Optimizations
- **Indexes**: Strategic indexing on foreign keys and unique constraints
- **Decimal Precision**: Financial calculations using Decimal type
- **Query Optimization**: Ecto query optimization patterns

### Real-time Performance
- **PubSub**: Efficient message broadcasting
- **LiveView Streaming**: Large dataset handling
- **Connection Pooling**: Database connection management

## Extensibility Points

### Parser Framework
- Modular parser architecture for different brokers
- Pluggable import formats
- Validation and error handling patterns

### Exchange Integration
- Client abstraction for multiple data providers
- Polling behavior customization
- Event-driven architecture for market data

### Reporting System
- Extensible report generation
- Custom calculation methods
- Export functionality hooks

## Development Guidelines

### Code Organization
- Context-based domain separation
- Schema validation with changesets
- Comprehensive error handling
- Type specifications for public functions

### Best Practices
- Pattern matching over conditional logic
- Immutable data structures
- Supervisor trees for fault tolerance
- Comprehensive test coverage

## Risk Assessment

### Technical Risks
- **Market Data Dependencies**: External API reliability (Medium Likelihood, Medium Impact)
- **Financial Calculations**: Accuracy critical for user decisions (Low Likelihood, High Impact)
- **Data Import Complexity**: Broker format changes (Medium Likelihood, Medium Impact)

### Operational Risks
- **Database Performance**: Large portfolio calculations (Medium Likelihood, Medium Impact)
- **Real-time Updates**: LiveView scaling under load (Low Likelihood, Medium Impact)
- **User Data Security**: Financial information protection (Low Likelihood, High Impact)

## Future Enhancement Opportunities

### Feature Expansion
- Additional broker importers
- Portfolio analytics and insights
- Graphical Charts
- Mobile application support

### Technical Improvements
- Advanced caching strategies
- Machine learning for portfolio optimization

## Conclusion

Profitry represents a well-architected Elixir/Phoenix application that successfully combines functional programming principles with modern web development practices. The modular monolith approach provides simplicity while maintaining clear domain boundaries, making it suitable for both current needs and future scaling requirements. The comprehensive testing strategy, deployment automation, and adherence to Elixir/OTP best practices position it as a maintainable and robust investment tracking solution.
