# argocd-in-one-shot
ArgoCD In One Shot is your one stop solution to learn and implement ArgoCD from Zero to Hero in DevOps

Below is complete syllabus for ArgoCD in One shot:

---

## [Chapter 1: Intro to GitOps & ArgoCD (Beginner)](./Chapter%201%20Intro%20to%20GitOps%20%26%20ArgoCD/)

- What is GitOps
- GitOps Principles: Declarative, Versioned, Automated, Observable
- GitOps vs Traditional CI/CD

---

## [Chapter 2: ArgoCD Basics (Beginner)](./Chapter%202%20ArgoCD%20Basics/)

- What is ArgoCD?
- Why ArgoCD for GitOps?
- ArgoCD vs Flux CD vs Jenkins X
- **ArgoCD Architecture** (https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png)
    - API Server
    - Repo Server
    - Application Controller
    - UI/CLI
- **Key ArgoCD Concepts:**
    - Application
    - Project
    - Health Status (Healthy, Degraded, Progressing, Missing)
    - Rollbacks
    - Auto-Healing (demo: delete pod → ArgoCD restores)
    - **Sync / Sync Policies**
        - Manual
        - Automatic
        - Sync Waves
        - Sync Hooks (PreSync, Sync, PostSync, SyncFail)
        - Flags (`-prune`, `-replace`, etc.)

---

## [Chapter 3: Setup & Installation (Beginner)](./Chapter%203%20Setup%20%26%20Installation/)

- Prerequisites (KIND/EKS, kubectl, Helm, Git repo)
- Installing ArgoCD on Kubernetes (kind)
- Exposing ArgoCD and accessing it on the Browser
- Logging in (UI + CLI walkthrough)

---

## [Chapter 4: First App Deployment (Beginner)](./Chapter%204%20First%20App%20Deployment/)

- Deploying the first NGINX app via ArgoCD
- Application CRD walkthrough(manifest file)
- Manual Sync vs Auto Sync demo
- Auto-healing demo (delete pod → auto restore)
- Declarative GitOps workflow (change in Git → sync in ArgoCD)

---

## [Chapter 5: ArgoCD Features (Intermediate)](./Chapter%205%20ArgoCD%20Features/)

- ArgoCD Projects (multi-team isolation + RBAC)
- App of Apps pattern (managing multiple apps hierarchically)
- Multi-cluster management (one ArgoCD → many clusters)
- ApplicationSets (deploying apps across multiple clusters/environments)
- Config Management:
    - Helm integration
    - Kustomize integration
    - Jsonnet

---

## [Chapter 6: Argo Rollouts (Intermediate)](./Chapter%206%20Argo%20Rollouts/)

- What is Argo Rollouts?
- Canary & Blue/Green deployments with ArgoCD
- Demo: Rolling update → Canary → Rollback

---

## [Chapter 7: Argo Workflows (Intermediate)](./Chapter%207%20Argo%20Workflows/)

- What is Argo Workflows? (K8s-native CI engine)
- Defining workflows (build → test → deploy)
- Example: Workflow pipeline integrated with ArgoCD

---

## [Chapter 8: Argo Events (Intermediate)](./Chapter%208%20Argo%20Events/)

- Event-driven GitOps (triggers from GitHub, Webhooks, Cloud events)
- Use cases: trigger deployments on push, PR merge, image update
- Demo: GitHub webhook → ArgoCD sync

---

## [Chapter 9: Argo Notifications (Intermediate)](./Chapter%209%20Argo%20Notifications/)

- Notification system overview
- Integrating with Slack, Microsoft Teams, Email
- Demo: Slack or email alert for sync failure

---

## [Chapter 10: Argo Image Updater (Advanced)](./Chapter%2010%20Argo%20Image%20Updater/)

- What is Image Updater?
- Automating image version updates in Git
- Demo: Auto-update app image → Git commit → ArgoCD sync

---

## [Chapter 11: Monitoring the Argo Suite (Advanced)](./Chapter%2011%20Monitoring%20the%20Argo%20Suite/)

- Observability with Prometheus + Grafana
- Logs with Loki
- Example dashboards:
    - Sync success/failure
    - Application health trends
    - Audit trails

---

## [Chapter 12: Security & Scaling (Advanced)](./Chapter%2012%20Security%20%26%20Scaling/)

- RBAC in ArgoCD (role-based access control)
- SSO with Dex/OIDC (GitHub, Google, LDAP)
- Scaling ArgoCD for high availability (HA setup)
- GitOps best practices for enterprises

---

## [Chapter 13: Real-World End-to-End Project (Advanced)](./Chapter%2013%20Real-World%20End-to-End%20Project/)

- K8s to prod application (https://youtu.be/Y8oFew4MfqA?si=lXheLSVcIbx8kFQT)

---

## [Chapter 14: Interview Questions & Industry Use Cases (Mixed)](./Chapter%2014%20Interview%20Questions%20%26%20Industry%20Use%20Cases/)

- Common Interview Q&A:
    - Difference between ArgoCD and Flux?
    - Explain Sync Waves, Hooks, Flags.
    - How does ArgoCD auto-healing work?
    - How do you do Canary deployment with Argo?
    - How to manage secrets in GitOps (Vault, Sealed Secrets, SOPS)?
    - scenario-based and etc…