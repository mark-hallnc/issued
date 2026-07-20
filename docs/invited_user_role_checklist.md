# Invited user and organization role checklist

Use separate test accounts when checking these flows:

1. Owner creates Org A and invites `manager@example.com` as Manager.
2. `manager@example.com` signs in and joins Org A as Manager, without seeing owner setup or owner-only controls.
3. Give one account Worker membership in Org A and Manager membership in Org B.
4. Sign in as that account and confirm the organization chooser lists both organizations and the correct role for each.
5. Select Org A and confirm Worker permissions apply.
6. Switch to Org B and confirm Manager permissions apply.
7. With one pending invite and no memberships, confirm sign-in accepts the invite and opens its organization automatically.
8. With multiple memberships or any invite alongside an existing membership, confirm sign-in shows the chooser.
