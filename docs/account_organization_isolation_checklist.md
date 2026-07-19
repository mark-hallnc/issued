# Account and organization isolation checklist

Use this checklist when changing authentication, organization selection, local
cache behavior, or plan usage:

1. Sign in as owner A and create a location and item.
2. Sign out, then sign in as a brand-new user B on the same device.
3. Confirm B sees no locations, items, local PIN users, or usage from A.
4. Create B's organization and confirm B sees only B's organization data.
5. Confirm the new organization counts its active owner as 1 user slot.
6. Switch back to A and confirm cloud data is pulled only for A's organization.

The current MVP local schema does not include organization IDs on operational
tables. Until that deeper migration is implemented, an account or organization
change swaps the unscoped organization cache while preserving the database,
global plan definitions, authentication session, and workspace-keyed sync
outbox.
