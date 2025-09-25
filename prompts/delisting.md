# Delisting Feature Plan

## Business Requirements

### Core Functionality
- Flag positions as delisted with zero valuation for stocks/options
- Support cash payouts per share (e.g., $0.10/share)
- Preserve order history and maintain P/L consistency
- Clear UI indicators showing delisted status
- Support import workflow where delistings can be created separately and later associated with positions

## Technical Design

### Data Model
**Chosen approach**: Normalized design with separate Delisting entity
**Rationale**: After discussing both normalized (separate Delisting table) and denormalized (delisting fields on Position) approaches, we chose the normalized approach. This provides better data integrity, clearer separation of concerns, and follows the existing patterns used for `Splits` and `TickerChanges` in the codebase.

### Schema Design
- **Delisting entity** with `ticker` reference (following Splits pattern)
- **Fields**: `delisted_on` (date), `payout` (decimal, default 0.00), `ticker` (string)
- **Constraints**: Unique `ticker` (one delisting per ticker), non-negative payout
- **Independence**: Delistings can exist regardless of position lifecycle

### Context Integration
**Design requirement**: Delisting functionality must be implemented as part of the existing `Investment` context, not as a separate context. This follows the established pattern where Splits and TickerChanges are also part of the Investment context with appropriate delegate functions in the main Investment module.

### Schema Design
```elixir
# delisting.ex
def changeset(delisting, attrs) do
  delisting
  |> cast(attrs, [:delisted_on, :payout, :position_id])
  |> validate_required([:delisted_on, :payout, :position_id])
  |> validate_number(:payout, greater_than_or_equal_to: 0)
  |> assoc_constraint(:position)
  |> unique_constraint(:position_id, message: "Position already delisted")
end
```

### Context Functions
- `create_delisting(attrs)` - Create new delisting record
- `update_delisting(delisting, attrs)` - Update existing delisting
- `list_delistings()` - List all delistings
- `find_delisting(id)` - Find delisting by ID
- `get_delisting!(id)` - Get delisting by ID (raises if not found)
- `delete_delisting(delisting)` - Delete delisting record
- `change_delisting(delisting, attrs)` - Prepare changeset
- `ticker_delisted?(ticker)` - Check if ticker is delisted (NEW)
- `get_delisting_by_ticker(ticker)` - Get delisting by ticker symbol (NEW)

**Functions to Remove:**
- `position_delisted?(position_id)` - Replaced by ticker-based lookup
- `find_delisting(position_id)` - Replaced by ticker-based lookup

## Design Update Required

### 🔄 Schema Migration Update
- **Task**: Update migration to use `ticker` instead of `position_id`
- **File**: `priv/repo/migrations/20250920151055_create_delistings.exs`
- **Changes**: Replace `position_id` foreign key with `ticker` field using `citext` type
- **Constraints**: Unique index on `ticker`, remove cascade delete
- **Performance**: Add index on `ticker` field for fast lookups

### 🔄 Schema Code Update
- **Task**: Update delisting schema to use `ticker` field
- **File**: `lib/profitry/investment/schema/delisting.ex`
- **Changes**: Remove position association, add ticker validation

### 🔄 Context Functions Update
- **Task**: Update context functions to work with ticker-based lookup
- **File**: `lib/profitry/investment/delistings.ex`
- **Changes**: Update functions to use `ticker` instead of `position_id`
- **Integration**: Use `Investment.find_recent_ticker/1` for ticker resolution
- **New Functions**:
  - `ticker_delisted?(ticker)` to check delisting status by ticker
  - `get_delisting_by_ticker(ticker)` to find delisting by ticker symbol
- **Remove Functions**:
  - `position_delisted?(position_id)` - position-based lookup
  - `find_delisting(position_id)` - position-based lookup

### �TestFixture Updates
- **Task**: Update test fixtures to use ticker-based approach
- **File**: `test/support/fixtures/investment_fixtures.ex`
- **Changes**: Remove position dependency from delisting fixtures

## Completed Implementation (Requires Updates)

### ⚠️ Database Migration
- File: `priv/repo/migrations/20250920151055_create_delistings.exs`
- Status: Created but needs update for ticker-based design
- Current: Uses position_id foreign key
- Needed: Change to ticker string field

### ⚠️ Schema Implementation
- File: `lib/profitry/investment/schema/delisting.ex`
- Status: Implemented but needs update for ticker-based design
- Current: Has position association
- Needed: Remove position association, use ticker field

### ⚠️ Context Module
- File: `lib/profitry/investment/delistings.ex`
- Status: Implemented but needs update for ticker-based design
- Current: Functions use position_id
- Needed: Update to use ticker-based lookup

### ⚠️ Test Fixtures
- File: `test/support/fixtures/investment_fixtures.ex`
- Status: Added but needs update for ticker-based design
- Current: Depends on position fixtures
- Needed: Standalone ticker-based fixtures

### ✅ Schema Tests
- File: `test/profitry/investment/schema/delisting_test.exs`
- Tests for changeset validation, required fields, constraints

### ✅ Context Tests
- File: `test/profitry/investment/delistings_test.exs`
- Tests for all CRUD operations

### ✅ Schema Implementation
- File: `lib/profitry/investment/schema/delisting.ex`
- Implemented Delisting schema with validation
- Added proper relationships and constraints

### ✅ Context Module
- File: `lib/profitry/investment/delistings.ex`
- Implemented CRUD operations
- Added to main Investment context with delegates

### ✅ Test Fixtures
- File: `test/support/fixtures/investment_fixtures.ex`
- Added `delisting_fixture/1` and `delisting_fixture/2` functions

### ✅ Schema Tests
- File: `test/profitry/investment/schema/delisting_test.exs`
- Tests for changeset validation, required fields, constraints

### ✅ Context Tests
- File: `test/profitry/investment/delistings_test.exs`
- Tests for all CRUD operations

## Remaining Tasks

### 🔄 Update Reports Module
- **File**: `lib/profitry/investment/reports.ex`
- **Task**: Modify valuation logic to handle delisted positions
- **Approach**: Use pattern matching to detect delisted positions
- **Integration**: Use `Investment.find_recent_ticker/1` to resolve ticker changes
- **Implementation**: In `calculate_report/2`, check if position ticker is delisted
- **Expected Behavior**: Delisted positions should return zero value plus any payout
- **Payout Logic**: Calculate payout as `shares * payout_per_share`

### 🔄 Reports Tests
- **File**: `test/profitry/investment/reports_test.exs`
- **Task**: Add test cases for delisted position valuation
- **Coverage**: Zero valuation, payout calculation, P/L consistency

### 🔄 LiveView Components
- **Files**: Create delisting-related LiveViews
- **Components**: Delisting index, show, new, edit forms
- **Integration**: With existing positions interface

### 🔄 Routes
- **File**: `lib/profitry_web/router.ex`
- **Task**: Add delisting routes
- **Pattern**: Follow existing RESTful conventions

### 🔄 Position UI Updates
- **Files**: Position LiveViews and templates
- **Task**: Show delisting status indicators
- **UI Elements**: Badges, warnings, disabled actions for delisted positions

### 🔄 End-to-End Testing
- **Task**: Run full test suite
- **Validation**: Ensure no regressions in existing functionality
- **Coverage**: Delisting workflows and edge cases

### User Experience
- **Clear Indicators**: Delisted status should be immediately visible
- **Disabled Actions**: Prevent trading/modification of delisted positions
- **Payout Clarity**: Show payout amounts together with delisted status in orders view.
- **Import Workflow**: Support creating delistings separately and later associating them with positions, similar to the existing import workflows for other position-related data.

## Success Criteria

1. **Data Integrity**: Delisted positions cannot be modified accidentally
2. **Valuation Accuracy**: Zero value + payout calculation is correct
3. **P/L Consistency**: Historical P/L remains accurate after delisting
4. **UI Clarity**: Users can easily identify delisted positions
5. **Test Coverage**: All functionality covered by automated tests
6. **Performance**: No significant impact on application performance
