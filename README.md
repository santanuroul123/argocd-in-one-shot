# argocd-in-one-shot
ArgoCD In One Shot is your one stop solution to learn and implement ArgoCD from Zero to Hero in DevOps

Below is complete syllabus for ArgoCD in One shot:

---

## [Chapter 1: Intro to GitOps & ArgoCD (Beginner)](./01_intro_to_gitops_argocd/)

- What is GitOps
- GitOps Principles: Declarative, Versioned, Automated, Observable
- GitOps vs Traditional CI/CD

---

## [Chapter 2: ArgoCD Basics (Beginner)](./02_argocd_basics/)

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
    - Repositories
    - Health Status (Healthy, Degraded, Progressing, Missing)
    - Rollbacks
    - Auto-Healing (demo: delete pod → ArgoCD restores)
    - **Sync / Sync Policies**
        - Manual
        - Automatic
        - Sync Waves
        - Sync Hooks (PreSync, Sync, PostSync, SyncFail)
        - Flags (`-prune`, `-replace`, etc.)
    - Sync Options
        - Skip Schema Validation
        - Auto-Create Namespace
        - Prune Last
        - Apply Out of Sync Only
        - Respect Ignore Differences
        - Server-Side Apply

---

## [Chapter 3: Setup & Installation (Beginner)](./03_setup_installation/)

- Prerequisites (KIND/EKS, kubectl, Helm, Git repo)
- Installing ArgoCD on Kubernetes (kind)
- Exposing ArgoCD and accessing it on the Browser
- Logging in (UI + CLI walkthrough)

---

## [Chapter 4: First App Deployment (Beginner)](./04_first_app_deployment/)

- Deploying the first NGINX app via ArgoCD
- Application CRD walkthrough(manifest file)
- Manual Sync vs Auto Sync demo
- Auto-healing demo (delete pod → auto restore)
- Declarative GitOps workflow (change in Git → sync in ArgoCD)

---

## [Chapter 5: ArgoCD Features (Intermediate)](./05_argocd_features/)

- ArgoCD Projects (multi-team isolation + RBAC)
- App of Apps pattern (managing multiple apps hierarchically)
- Multi-cluster management (one ArgoCD → many clusters)
- ApplicationSets (deploying apps across multiple clusters/environments)
- Config Management:
    - Helm integration
    - Kustomize integration
    - Jsonnet

---

## [Chapter 6: Argo Rollouts (Intermediate)](./06_argo_rollouts/)

- What is Argo Rollouts?
- Canary & Blue/Green deployments with ArgoCD
- Demo: Canary → Rollback

---

## [Chapter 7: Argo Workflows (Intermediate)](./07_argo_workflows/)

- What is Argo Workflows? (K8s-native CI engine)
- Defining workflows (build → test → deploy)

---

## [Chapter 8: Argo Events (Intermediate)](./08_argo_events/)

- Argo-Workflow trigger using Argo Events
---

## [Chapter 9: Argo Notifications (Intermediate)](./09_argo_notifications/)

- Notification system overview
- Integrating with Slack, Email
- Demo: Slack or email alert for sync failure

---

## [Chapter 10: Argo Image Updater (Advanced)](./10_argo_image_updater/)

- What is Image Updater?
- Automating image version updates in Git
- Demo: Auto-update app image → Git commit → ArgoCD sync

---

## [Chapter 11: Monitoring the Argo Suite (Advanced)](./11_monitoring_the_argosuite/)

- Observability with Prometheus + Grafana
- Logs with Loki
- Example dashboards:
    - Sync success/failure
    - Application health trends
    - Audit trails

---

## [Chapter 12: Security & Scaling (Advanced)](./12_security_scaling/)

- RBAC in ArgoCD (role-based access control)
- SSO with Dex/OIDC (GitHub, Google, LDAP)
- Scaling ArgoCD for high availability (HA setup)
- GitOps best practices for enterprises

---

## [Chapter 13: Real-World End-to-End Project (Advanced)](./13_real_world_end_to_end_project/)

- K8s to prod application (https://youtu.be/Y8oFew4MfqA?si=lXheLSVcIbx8kFQT)

---

## [Chapter 14: Interview Questions & Industry Use Cases (Mixed)](./14_interview_questions_industry_use_cases/)

- Common Interview Q&A:
    - Difference between ArgoCD and Flux?
    - Explain Sync Waves, Hooks, Flags.
    - How does ArgoCD auto-healing work?
    - How do you do Canary deployment with Argo?
    - How to manage secrets in GitOps (Vault, Sealed Secrets, SOPS)?
    - scenario-based and etc…