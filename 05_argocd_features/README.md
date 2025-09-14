# Chapter 5: ArgoCD Features (Intermediate)

In this chapter, we’ll explore the **intermediate features of ArgoCD** that make it suitable for real-world, production-grade GitOps workflows.
These include **Projects, App of Apps, Multi-cluster management, ApplicationSets, and integrations with Helm, Kustomize, and Jsonnet.**

---

## Topics Covered

1. **ArgoCD Projects** → multi-team isolation + RBAC
2. **App of Apps pattern** → managing multiple apps hierarchically
3. **Multi-cluster management** → single ArgoCD instance managing many clusters
4. **ApplicationSets** → deploying apps across multiple clusters/environments automatically
5. **Config Management Tools**:

   * Helm integration
   * Kustomize integration
   * Jsonnet integration

---

## Hands-On Learning Paths

👉 Click below to explore each feature with examples:

1. [Projects (Multi-Team Isolation + RBAC)](./projects/README.md)

   * Create and assign applications to Projects
   * Restrict namespaces and repos per team

2. [App of Apps Pattern](./app_of_apps/README.md)

   * Root application managing multiple child apps
   * Easier onboarding, hierarchical management

3. [Multi-Cluster Management](./multicluster/README.md)

   * Register multiple clusters
   * Deploy applications to different clusters

4. [ApplicationSets](./applicationsets/README.md)

   * Generate multiple applications dynamically
   * List, Git, and Cluster generators demo

5. [Config Management Tools](./config_management/README.md)  -  have to add in this chapter

   * Deploy apps using Helm charts
   * Manage environment-specific configs with Kustomize
   * Use Jsonnet for advanced templating

---

Happy Learning!