# vikunja

User managed secrets:

- vikunja/vikunja-db
    *keys:* `user`, `passwd`
- vikunja/vikunja-secret
    *keys:* `secret`
- vikunja/vikunja-s3
    *keys:* `accesskey`, `secretkey`

Database `vikunja` (owned by the above user) must exist on
`cloudnative-pg/postgres16`.

Bucket `vikunja` must exist on `rustfs`, readable and writable with the above
access key. Attachments, avatars and backgrounds are stored there, the
deployment itself is stateless.

Registration is disabled, create users with:

```bash
kubectl -n vikunja exec -it deploy/vikunja -- /app/vikunja/vikunja user create \
    -u USERNAME -e EMAIL
```
