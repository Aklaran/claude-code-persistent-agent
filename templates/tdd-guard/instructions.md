### Import & Exercise Validation
- Tests MUST import and exercise the actual source module under test
- Tests must NEVER reimplement, copy, or inline business logic from the SUT
- If a test computes an expected value using the same algorithm as the SUT,
  that is a violation — expected values should be hardcoded literals or
  derived from independent reasoning
- Mock BOUNDARIES (I/O, network, UI), not the logic under test
