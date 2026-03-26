Create secret `influxdb-auth` with keys `admin-password` and `admin-token`.
```
apiVersion: v1
kind: Secret
metadata:
  name: influxdb-auth
type: Opaque
data:
  admin-password: ...
  admin-token: ...
```
