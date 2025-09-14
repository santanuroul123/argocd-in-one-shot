# Chapter 14 - Interview Questions

This chapter contains a collection of common interview questions related to ArgoCD and GitOps practices, along with their answers. These questions are designed to help you prepare for interviews in the field of DevOps and continuous delivery using ArgoCD.

---

### ArgoCD & GitOps Real-World Interview Questions and Scenario-Based Answers

***

**Q1: What is ArgoCD and how does it implement GitOps for Kubernetes?**  
**A:** ArgoCD is a Kubernetes-native continuous delivery tool that follows GitOps principles. It continuously monitors Git repositories containing declarative Kubernetes manifests and ensures the live cluster's state matches the desired state defined in Git, enabling automated, version-controlled deployments with self-healing capabilities.

***

**Q2: How does ArgoCD differ from traditional CI/CD tools like Jenkins?**  
**A:** Unlike Jenkins, which primarily focuses on CI pipelines, ArgoCD specializes in continuous delivery via a GitOps approach. It treats Git as the single source of truth and uses a pull-based approach to sync the cluster state, providing declarative Kubernetes deployments with automatic drift detection and reconciliation.

***

**Q3: How would you troubleshoot an 'OutOfSync' application status in ArgoCD?**  
**A:** First, check the Git repo changes have been committed and pushed correctly. Verify that ArgoCD has the proper access to your cluster and Git repo. Inspect the sync logs for errors. Also validate the manifests for errors or Kubernetes API incompatibility. Manual syncing can confirm if the problem resolves.

***

**Q4: Scenario:** You deployed a new app version via ArgoCD but it introduced issues causing degraded pod health. How do you rollback?  
**A:** ArgoCD supports automatic rollbacks via the UI or CLI. You can revert to a previous Git commit or select a previously healthy application revision to redeploy. This immediately reconciles the cluster state with the chosen version, mitigating outages quickly.

***

**Q5: What are ArgoCD Sync Waves and how do they help in deployment orchestration?**  
**A:** Sync Waves allow ordering of resource deployment by assigning them wave priorities. Resources in a lower-numbered wave sync before those in higher numbers, enabling multi-step deployments where namespaces or CRDs are created first, followed by dependent resources. This is critical for complex apps.

***

**Q6: How do you implement multi-cluster management using ArgoCD?**  
**A:** Register multiple Kubernetes clusters with ArgoCD. Use ApplicationSets with cluster generators to automatically create and manage applications per cluster. This approach centralizes GitOps management while scaling across environments or regions.

***

**Q7: Scenario:** Your team wants to be notified immediately if any application in ArgoCD enters a degraded state. What is the setup?  
**A:** Configure ArgoCD Notifications by deploying the notification controller. Define triggers for health status changes such as `application.degraded`. Set up channels like email, Slack, or MS Teams, and map triggers to these channels. This ensures real-time alerts on deployment issues.

***

**Q8: Explain how ArgoCD handles secrets management securely.**  
**A:** ArgoCD integrates with external secret management tools like SealedSecrets, SOPS, and HashiCorp Vault to encrypt secrets stored in Git repos. Secrets are decrypted at sync time in the cluster, ensuring sensitive data is never stored in plaintext Git. RBAC and SSO add further access control.

***

**Q9: How can Argo Rollouts be used for advanced deployment strategies?**  
**A:** Argo Rollouts extends ArgoCD for progressive delivery such as canary and blue/green deployments. It provides fine-grained traffic shifting, automated analysis using metrics (e.g., Prometheus), and automatic rollback on failure, enabling reduce risk during production deployments.

***

**Q10: Scenario:** You want to automate container image updates in your applications tracked by ArgoCD. What strategy do you use?  
**A:** Implement ArgoCD Image Updater, which monitors container registries for new image tags and automatically commits updated manifests to Git. ArgoCD then syncs the cluster with these updates, enabling continuous delivery of new versions with minimal manual intervention.[1]

***

**Q11: What are common security best practices when using ArgoCD in enterprise environments?**  
**A:** Use RBAC for fine-grained permissions, integrate SSO via OAuth2/OIDC providers for user authentication, encrypt secrets, enable HTTPS for secure API access, and deploy ArgoCD in HA mode with redundancy. Regularly audit permissions and update ArgoCD components.

***

**Q12: How do you manage environment-specific configurations in ArgoCD?**  
**A:** Use Helm charts with environment-specific values, Kustomize overlays, or Jsonnet templates stored in Git. This allows maintaining configuration DRYness while customizing deployments per environment (dev, staging, prod) through parameterized manifests synchronized by ArgoCD.

***

**Q13: Scenario:** Your ArgoCD UI shows 'unknown' health status for all applications. What steps do you take?  
**A:** Verify that ArgoCD has the necessary permissions to query resources and statuses. Check if custom health checks/scripts are in place and functioning. Inspect controller logs for errors, confirm cluster API connectivity, and validate correct versions of CRDs and dependencies.

***

**Q14: How does ArgoCD implement self-healing? Provide an example.**  
**A:** ArgoCD continuously monitors the cluster state and compares it with the Git-declared desired state. If a resource like a pod is deleted or altered, ArgoCD automatically re-applies the manifests to restore the desired state. For example, deleting a pod causes ArgoCD to detect drift and recreate the pod within seconds.

***

**Q15: What is the difference between manual and automatic sync policies in ArgoCD? When would each be used?**  
**A:** Manual sync requires explicit triggering by users to sync changes, suitable for production where controlled releases are needed. Automatic sync applies changes immediately when detected, ideal for development or test environments to accelerate feedback cycles.

***

Happy Learning!
