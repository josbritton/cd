# cd

## Prerequisites

1. Working Kubernetes cluster
2. Working `kubectl` config

```bash
kubectl get nodes
```

```no-lang
NAME                            STATUS   ROLES           AGE     VERSION
k8s1.private.swifthomelab.net   Ready    control-plane   3m54s   v1.28.6
k8s2.private.swifthomelab.net   Ready    control-plane   3m36s   v1.28.6
k8s3.private.swifthomelab.net   Ready    control-plane   3m3s    v1.28.6
```

## Initial installation on bare cluster

(ArgoCD-cli installation not necessary)

1. Create the ArgoCD namespace

    ```bash
    kubectl create namespace argocd
    ```

2. Bootstrap ArgoCD and wait for it to come up

    ```bash
    kubectl apply -n argocd -k bootstrap/install --server-side \
        && kubectl -n argocd rollout status deployment argocd-server
    ```

3. Install root application

    ```bash
    kubectl apply -f defs/root.yaml
    ```

Base application definition

- `argo-cd` manages argo-cd installtion itself, reconciles ownership of
resources after initial installation with step 1.
- `root` manages applications in 'app-of-apps' pattern on `default` project
- `cluster-resources` owns global cluster resources that should be preserved on
application deletion (like the `argocd` namespace)

1. Update ArgoCD user password
    1. Generate password hash using bcrypt ([Python implementation](https://pypi.org/project/bcrypt/))

        ```bash
        python3 -I
        ```

        ```python
        >>> import bcrypt
        >>> print(bcrypt.hashpw(b'YOUR-PASSWORD-HERE', bcrypt.gensalt()).decode())
        >>> exit()
        ```

    2. Create ArgoCD admin secret with new hash

        ```bash
        kubectl apply -f ./secrets/argocd.yaml
        ```

        ```yaml
        # ./secrets/argocd.yaml
        apiVersion: v1
        stringData:
          admin.password: YOUR-PASSWORD-HASH
        kind: Secret
        metadata:
          labels:
            app.kubernetes.io/name: argocd-secret
            app.kubernetes.io/part-of: argocd
          name: argocd-secret
          namespace: argocd
        type: Opaque
        ```

    3. Update password mtime

        ```bash
        kubectl -n argocd patch secret argocd-secret \
            -p '{"stringData": {"admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
        ```

    > You could also install the ArgoCD CLI and update passwords via

    ```bash
    argocd account update-password
    ```

2. Forward ArgoCD server on loopback port 8443/HTTPS

    > <http://service:443/> -> <http://localhost:8443/>

    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8443:443
    ```

3. Sign-in to ArgoCD via web UI using new password

4. Manually sync all applications
    <!-- <insert screenshot> -->

5. Restart admin server to apply HTTPs patch

    ```bash
    kubectl -n argocd rollout restart deployment argocd-server \
        && kubectl -n argocd rollout status deployment argocd-server
    ```

6. ArgoCD is now available at ingress (done)

    <!-- 7. Patch ArgoCD to listen to HTTP and reject HTTPS -->
    <!-- ```bash -->
    <!-- kubectl -n argocd patch cm argocd-cmd-params-cm \ -->
    <!--     -p '{"data": {"server.insecure": "true"}}' -->
    <!-- ``` -->
    <!---->

Note: `https://kubernetes.default.svc` is the default address for the local
cluster that ArgoCD is installed in. If ArgoCD should manage an external
cluster, this address must be changed.

This repository follows the *app of apps* [pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern).
Manual pinning of cluster version and strict access control is necesarry due to
the inherent danger of auto-bootstrapping clusters.

<!-- ## Signing-in to Kubernetes dashboard -->
<!---->
<!-- ```bash -->
<!-- kubectl -n kubernetes-dashboard create token admin -->
<!-- kubectl -n kubernetes-dashboard get secret admin -o jsonpath={".data.token"} | base64 -d -->
<!-- ``` -->
