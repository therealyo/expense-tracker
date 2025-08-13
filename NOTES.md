# NOTES

## Money and currency handling

- Amounts are stored as integer cents in the database (integer), to avoid floating-point issues.
- Parsing user input:
  - `ExpenseTracker.Currencies.normalize_money/2` converts dollar strings (e.g., "10", "10.5", "10.50", ".99", "$10.50") to integer cents using `parse_dollars_to_cents/1`.
  - This normalization runs in changesets for `Category.monthly_budget` and `Expense.amount`.
- Displaying values:
  - Forms show dollar values in decimal format to users.
  - In LiveViews, money inputs set `value` via `Currencies.format_cents/2` and trim the leading "$" for numeric inputs. This fixes incorrect values during edit/validate.

### Extending to multiple currencies

- Schema:
  - Category and Expense include a `currency` field as `Ecto.Enum`. Currently only `:USD` is enabled.
- Steps to extend:
  - Add more currencies to `@available_currencies` in `Currencies`.
  - Expand `format_cents/2` to format symbols/placement per currency (use a map: code -> symbol, decimals, separators).
  - Validation: ensure currency is valid. 
  - Conversions: query exchange data and cache with periodical updates.
  
## Architectural decisions

- Phoenix LiveView for forms and views:
- Money as cents: central parsing/validation in changesets, no floats.
- Preloading and derived fields: Categories preload `:expenses`; `total_spent` is a virtual field computed by `Category.with_total_spent/1`.

## Trade-offs and shortcuts

- Money parsing and validations are limited to USD for now, because we don't need to handle other currencies
- Total Spent calculates at runtime - can be optimized
- Categories index page does not update in realtime if new category added
- Overflowing category budget is not forbidden as well as no max value for amount and budget
- Missing type specs and overall type hints
- Part of UI, money conversions and tests are build using AI

## Testing strategy

- Unit tests: contexts and currency helpers
  - `Currencies` parsing/formatting
  - Category and Expense changesets (required fields, currency inclusion, non-negative amounts)
- LiveView tests: `Phoenix.LiveViewTest` with selectors and form interactions; validate edit/validate flow.
- Future: add tests for nested expenses add/remove/sort; edge cases for money parsing and maximum values; multi-currency formatting 
