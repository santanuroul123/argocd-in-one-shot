# Chapter 9: Security & Scaling in ArgoCD

As you start using ArgoCD in production, **security and scalability** become critical. This chapter explains RBAC (role-based access control), local users, SSO with Dex/OIDC, scaling ArgoCD for high availability, and GitOps best practices for enterprises. We'll go step by step, with concepts, examples, and YAML manifests.

---

## Prerequisites

- A running Kubernetes cluster.
- kubectl configured to access the cluster.
- ArgoCD server installed and running.
- argocd CLI installed & Logged in (keep argocd login password, needed to update password).
- Helm 3.x installed.
- Administrative access to your OAuth/OIDC provider (GitHub, Okta, Google, etc.) for SSO setup (we will use GitHub in this guide).

> Use this guide to setup ArgoCD & Kind Cluster [README.mc](../03_setup_installation/README.md) or Run this Shell script [setup_argocd.sh](../03_setup_installation/setup_argocd.sh)

---

## 1. User Management in ArgoCD

### Built-in Admin User

ArgoCD comes with **one built-in admin user** that has full system access. According to official documentation:
- Use the admin user **only for initial configuration**
- **Disable admin user** after creating additional users for security
- Switch to local users or configure SSO integration

### Local Users vs SSO

**Local users** serve two main use cases:
1. **API automation** - Generate tokens for CI/CD pipelines
2. **Small teams** - When SSO might be overkill

**SSO** is recommended for:
- **Enterprise environments** with existing identity providers
- **Advanced features** like groups, login history, centralized management

---

## 2. RBAC in ArgoCD (Role-Based Access Control)

### What is RBAC?

RBAC controls **who** (users/groups) can perform **what actions** on **which resources**. ArgoCD RBAC is defined in the `argocd-rbac-cm` ConfigMap.

### RBAC Components

- **Role** → Named set of permissions (e.g., `role:readonly`)
- **Policy** → Maps roles to allowed/denied actions
- **Subject** → User or group bound to a role

### RBAC Model Structure

ArgoCD uses **Casbin** syntax with two types:

**Group Assignment:**
```
g, <user/group>, <role>
```

**Policy Assignment:**
```
p, <role/user/group>, <resource>, <action>, <object>, <effect>
```

### Available Resources and Actions

Below is a table that summarizes all possible resources and which actions are valid for each of them.

| Resource\Action        | get | create | update | delete | sync | action | override | invoke |
|----------------|:---:|:------:|:------:|:------:|:----:|:------:|:--------:|:------:|
| applications   | ✅  |   ✅   |   ✅   |   ✅   |  ✅  |   ✅   |    ✅    |   ❌   |
| applicationsets| ✅  |   ✅   |   ✅   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| clusters       | ✅  |   ✅   |   ✅   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| projects       | ✅  |   ✅   |   ✅   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| repositories   | ✅  |   ✅   |   ✅   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| accounts       | ✅  |   ❌   |   ✅   |   ❌   |  ❌  |   ❌   |    ❌    |   ❌   |
| certificates   | ✅  |   ✅   |   ❌   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| gpgkeys        | ✅  |   ✅   |   ❌   |   ✅   |  ❌  |   ❌   |    ❌    |   ❌   |
| logs           | ✅  |   ❌   |   ❌   |   ❌   |  ❌  |   ❌   |    ❌    |   ❌   |
| exec           | ❌  |   ✅   |   ❌   |   ❌   |  ❌  |   ❌   |    ❌    |   ❌   |
| extensions     | ❌  |   ❌   |   ❌   |   ❌   |  ❌  |   ❌   |    ❌    |   ✅   |

### Creating Local Users

Local users are defined in `argocd-cm` ConfigMap:

Create: [argocd-user-cm.yaml](argocd-user-cm.yaml)

**User Capabilities:**
- `apiKey` - Generate authentication tokens for API access
- `login` - Login using the UI

### Hands-On: Create Local Users

> [!NOTE]
>
> Firstly Update the Password of your current logged in user in ArgoCD i.e `admin`:
>
> ```bash
> argocd account update-password --current-password <current-password> --new-password <new-password>
> ```
>
> You can even do it by ArgoCD UI in `User Info`.
>
> After updating password, Log In to ArgoCD UI using new password for `admin`.
>

* Create local users in argocd-cm, Apply: 

  ```bash
  kubectl apply -f argocd-user-cm.yaml
  ```

  ![apply-output](output_images/image-1.png)

* Set passwords for users:

  ```bash
  argocd account update-password --account alice
  argocd account update-password --account bob
  ```
  
  > You need to pick a password that:
  >  * Is at least 8 characters long
  >  * No more than 32 characters
  >
  > I kept Password as: For alice: alice123, For bob: bob12345

  ![password-setup](output_images/image-2.png)


* List all users:

  ```bash
  argocd account list
  ```

  ![account-list](output_images/image-3.png)

* Get specific user details:

  ```bash
  argocd account get --account alice
  ```

  ![alice-info](output_images/image-4.png)

* For Now Open the ArgoCD Server Url (http:<instance_public_ip>:8080) into `Incognito` mode, and try to login as `alice`.
  1. Username: `alice`
  2. Password: `alice123` (or whatever you set)
    ![alice-login](output_images/image-5.png)

  > You can also login as `bob`.
  >
  > This is how we create new `local` user.

* If needed, you can disabled `admin` user, using: 

  ```bash
  kubectl patch -n argocd configmap argocd-cm --patch='{"data":{"admin.enabled": "false"}}'
  ```

* Similarly, You can enable `admin` user, using:

  ```bash
  kubectl patch -n argocd configmap argocd-cm --patch='{"data":{"admin.enabled": "false"}}'
  ```

### Example RBAC Policy

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Built-in roles
    p, role:readonly, applications, get, */*, allow
    p, role:readonly, applications, sync, */*, deny
    p, role:admin, applications, *, */*, allow

    # Custom roles
    p, role:developer, applications, get, myproject/*, allow
    p, role:developer, applications, sync, myproject/*, allow

    # Bind users to roles
    g, alice, role:readonly
    g, bob, role:admin
    g, my-org:dev-team, role:developer  # SSO group

  # Default role for authenticated users
  policy.default: role:readonly
  
  # Control which scopes to examine for RBAC
  scopes: '[groups, email]'
```

### Hands-On: Configure RBAC

Create: [argocd-rbac-cm.yaml](argocd-rbac-cm.yaml)

* Apply RBAC configuration
  ```bash
  kubectl apply -f argocd-rbac-cm.yaml
  ```

  ![rbac](output_images/image-6.png)

* Validate RBAC configuration

  ```bash
  argocd admin settings rbac validate --policy-file argocd-rbac-cm.yaml
  ```

  ![rbac-validate](output_images/image-7.png)

* Check specific user permissions
  * Check, whether user `alice` can get application or not:

    ```bash
    argocd admin settings rbac can alice get applications "myproject/*" -n argocd
    ```

    Yes `alice` can get application:
      
      ![alice-get](output_images/image-8.png)

  * Check whether `alice` can sync application or not:

    ```bash
    argocd admin settings rbac can alice sync applications "myproject/*" -n argocd
    ```

    Yes `alice` can sync application, as we defined in `rbac`:

      ![alice-sync](output_images/image-9.png)
  
  * Check whether `alice` can delete application or not (`alice` don't have delete permission)

    ```bash
    argocd admin settings rbac can alice delete applications "myproject/*" -n argocd
    ```

    No `alice` can't delete application:

      ![alice-delete](output_images/image-10.png)

  * Check whether `bob` can sync & delete application or not:

    ```bash
    argocd admin settings rbac can bob sync applications "*" -n argocd
    argocd admin settings rbac can bob delete applications "*" -n argocd
    ```

    Yes `bob` can sync & delete application:

      ![bob-sync](output_images/image-11.png)

    > Why `Yes`:
    > Because in our RBAC policy, we assigned `bob` to `role:admin`, which has all permissions (`*`).

* You can even verify in ArgoCD UI, by login with both `alice` & `bob`:

  * As `alice` you can only see (get) anything, you can not even add a repository, or create app.
  * As `bob` you can do anything, as `bob` has admin role.


**Best Practices:**
- Use `policy.default: role:readonly` for security
- Assign minimum required privileges
- Use groups instead of individual users when possible

---

## 3. SSO with Dex / OIDC

### Why SSO?

- **Centralized authentication** using corporate accounts
- **No separate credentials** to manage
- **Better security** and compliance
- **Group-based access** control

### SSO Options in ArgoCD

1. **Bundled Dex** - For providers that don't support OIDC (SAML, LDAP) or need Dex features
2. **Existing OIDC Provider** - Direct integration with Okta, Auth0, Google, etc.

### GitHub SSO with Dex

Dex is a built-in OIDC identity service bundled with ArgoCD, used when you want to connect to external identity providers (GitHub, Google, LDAP, SAML).

**Step 1: Register OAuth App in GitHub**
- Go to GitHub → Settings → Developer settings → OAuth Apps → New OAuth App
- Application name: `ArgoCD`
- Homepage URL: `https://argocd.example.com`
- Authorization callback URL: `https://argocd.example.com/api/dex/callback`

**Step 2: Configure ArgoCD**

`argocd-cm` ConfigMap:

Create: [argocd-github-cm.yaml](argocd-github-cm.yaml)

`argocd-secret`:

Create: [argocd-github-secret.yaml](argocd-github-secret.yaml)

### Hands-On: Enable GitHub SSO

```bash
# Create the secret with GitHub OAuth credentials
kubectl apply -f argocd-github-secret.yaml

# Update argocd-cm with Dex configuration
kubectl apply -f argocd-github-cm.yaml

# Restart ArgoCD server to apply changes
kubectl rollout restart -n argocd deployment argocd-server

# Verify SSO is working
kubectl logs -n argocd deployment/argocd-server | grep -i dex
```

### Direct OIDC Integration

For existing OIDC providers (Okta, Auth0, etc.):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  oidc.config: |
    name: Okta
    issuer: https://dev-123456.oktapreview.com
    clientID: aaaabbbbccccddddeee
    clientSecret: $oidc.okta.clientSecret
    requestedScopes: ["openid", "profile", "email", "groups"]
    requestedIDTokenClaims: {"groups": {"essential": true}}
```

---

## 4. Scaling ArgoCD for High Availability (HA)

### Why HA?

- **Prevents single points of failure**
- **Ensures continuous operation**
- **Required for production environments**

### ArgoCD HA Components

- **API Server** - Multiple replicas behind LoadBalancer
- **Repo Server** - Scales horizontally for Git operations  
- **Application Controller** - Supports leader election
- **Redis HA** - High availability caching with Sentinel
- **External Database** - PostgreSQL with replication (optional)

### HA Installation

**Official HA Manifests:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
```

**Scaling with kubectl:**
```bash
# Scale components manually
kubectl -n argocd scale deployment argocd-server --replicas=3
kubectl -n argocd scale deployment argocd-repo-server --replicas=2
kubectl -n argocd scale statefulset argocd-application-controller --replicas=2
```

### Hands-On: Deploy HA ArgoCD

```bash
# Deploy ArgoCD in HA mode
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml

# Wait for all pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Verify HA deployment
kubectl get pods -n argocd
kubectl get svc -n argocd

# Check if Redis HA is running
kubectl get pods -n argocd | grep redis

# Scale server replicas
kubectl -n argocd scale deployment argocd-server --replicas=3

# Verify scaling
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
```

**Helm HA Configuration:**

```yaml
controller:
  replicas: 2
server:
  replicas: 3
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
repoServer:
  replicas: 2
redis-ha:
  enabled: true
```

### HA Best Practices

- **Node Anti-Affinity** - Spread pods across nodes
- **Resource Limits** - Set appropriate CPU/memory limits
- **External Database** - Use managed PostgreSQL for large deployments
- **Load Balancer** - Use proper ingress for the API server

---

## 5. GitOps Best Practices for Enterprises

### Security Practices

- **Disable admin user** after initial setup
- **Use SSO only** - No local passwords in production
- **TLS everywhere** - Secure all communications
- **Secret management** - Use Vault, Sealed Secrets, or External Secrets
- **RBAC with least privilege** - Grant minimum necessary permissions
- **Audit logging** - Enable comprehensive logging

### Scaling Practices

- **AppProjects** - Isolate teams and environments
- **ApplicationSets** - Template applications across clusters
- **Sync waves** - Control deployment order
- **Resource quotas** - Prevent resource contention
- **Multi-cluster** - Separate management and workload clusters

### Operational Practices

- **Git as single source of truth** - All configurations in Git
- **PR-based workflows** - Enforce code reviews
- **Environment promotion** - dev → staging → prod
- **Monitoring and alerting** - Comprehensive observability
- **Disaster recovery** - Regular backups and tested restore procedures
- **Policy as Code** - Use OPA Gatekeeper for governance

### Hands-On: Enterprise Setup Example

```bash
# Create AppProject for team isolation
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-a
  namespace: argocd
spec:
  description: Team A Project
  sourceRepos:
  - 'https://github.com/team-a/*'
  destinations:
  - namespace: 'team-a-*'
    server: 'https://kubernetes.default.svc'
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  roles:
  - name: team-a-developers
    description: Developers for Team A
    policies:
    - p, proj:team-a:team-a-developers, applications, *, team-a/*, allow
    groups:
    - my-org:team-a-devs
EOF

# Apply resource quotas
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a-prod
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
EOF
```

***

## 6. Validation and Testing

### Test RBAC Policies

```bash
# Validate RBAC configuration
argocd admin settings rbac validate --policy-file rbac-policy.csv

# Test specific permissions
argocd admin settings rbac can alice get applications "myproject/*"
argocd admin settings rbac can alice sync applications "myproject/*"
argocd admin settings rbac can bob get applications "*"
```

### Test SSO Integration

```bash
# Check Dex configuration
kubectl logs -n argocd deployment/argocd-server | grep -i dex

# Test OAuth flow
curl -k "https://argocd.example.com/api/dex/auth/github"

# Verify user groups are mapped correctly
argocd admin settings rbac can "my-org:team-a-devs" sync applications "team-a/*"
```

### Verify HA Setup

```bash
# Check all components are running with multiple replicas
kubectl get pods -n argocd

# Test failover by deleting one replica
kubectl delete pod -n argocd $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}')

# Verify service is still accessible
kubectl get svc -n argocd argocd-server
```

***

## 7. Key Takeaways

- **Disable admin user** after initial configuration for security
- **Use local users** only for small teams or automation
- **Implement SSO** for enterprise environments with proper group mapping
- **Deploy HA** for production with proper resource allocation
- **Follow GitOps best practices** for security, scalability, and operational excellence
- **Test RBAC policies** before applying to production
- **Monitor and audit** all ArgoCD activities

With these configurations, your ArgoCD deployment becomes **secure, scalable, and enterprise-ready** following official best practices and recommendations.

---

Happy Learning!