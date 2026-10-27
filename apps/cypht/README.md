# cypht

User managed secrets:

- cypht/cypht-db
    *keys:* `user`, `passwd`
- cypht/cypht-admin
    *keys:* `user`, `passwd`

Database `cypht` (owned by the above user) must exist on
`cloudnative-pg/postgres16`. Tables are created and migrated by the container
on startup.

Authentication, sessions and user settings are stored in the database, the
deployment itself is stateless.

The `cypht-admin` account is created on startup if it does not already exist,
changing `passwd` afterwards has no effect. It is also the only entry in
`ADMIN_USERS`, which can create further accounts in the web UI, or with:

```bash
kubectl -n cypht exec -it deploy/cypht -- \
    php /usr/local/share/cypht/scripts/create_account.php USERNAME PASSWORD
```

IMAP/SMTP servers are configured per user in the web UI.
