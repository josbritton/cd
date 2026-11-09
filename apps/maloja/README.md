# maloja

User managed secrets:

- maloja/maloja-admin
    *keys:* `passwd`
- maloja/maloja-lastfm
    *keys:* `apikey`, `secret`, `sk`
- maloja/maloja-audiodb
    *keys:* `apikey`

The admin password is reapplied on every start, so rotating `passwd` takes effect
after the pod restarts.

Settings saved in the web UI are written to `/data/settings.ini`, which takes
precedence over the `MALOJA_*` environment in the manifest. Delete a line from
that file to fall back to the manifest value.

Maloja is single-user: there is one profile, its statistics pages are public,
and only the admin pages need the password.

Last.fm is used for artwork and as a proxy-scrobble target. `apikey` and `secret`
come from a Last.fm API account (the same values as `navidrome/lastfm-api`).
Forwarding only activates with a session key `sk`, obtained once with:

```bash
printf 'api key: ';    read -r key
printf 'api secret: '; read -rs secret; echo
printf 'username: ';   read -r user
printf 'password: ';   read -rs pass; echo
sig=$(printf 'api_key%smethodauth.getMobileSessionpassword%susername%s%s' \
    "$key" "$pass" "$user" "$secret" | md5sum | cut -d' ' -f1)
curl -fsS https://ws.audioscrobbler.com/2.0/ \
    --data-urlencode method=auth.getMobileSession \
    --data-urlencode "api_key=$key" \
    --data-urlencode "username=$user" \
    --data-urlencode "password=$pass" \
    --data-urlencode "api_sig=$sig"
```

## Scrobbling

On first start maloja generates an API key named `default` and prints it to the
log; delete it under *API Keys* in the admin UI and create one key per client.

Navidrome scrobbles through maloja's ListenBrainz API (in-cluster): create a
`navidrome` key, then enter it as the ListenBrainz token in Navidrome's personal
settings. Link only one Navidrome account, since every scrobble lands in the
same profile.

## Importing history

Every file in `/data/import/` is imported on startup (Last.fm, ListenBrainz,
Spotify and maloja exports):

```bash
kubectl -n maloja cp EXPORT_FILE maloja-0:/data/import/
kubectl -n maloja delete pod maloja-0
```

Remove the file once the import has finished:

```bash
kubectl -n maloja exec maloja-0 -- rm /data/import/EXPORT_FILE
```
