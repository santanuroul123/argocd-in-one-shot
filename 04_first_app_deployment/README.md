# Chapter 4: First App Deployment with ArgoCD

In this chapter, we will learn how to deploy applications with ArgoCD using **three different approaches**:  

1. **UI Approach** → NGINX example  
2. **CLI Approach** → Apache example  
3. **Declarative Approach** → Online Shop example  

Each method has its use cases, but only the **Declarative approach** aligns with the principles of GitOps.  

---

## 📂 Directory Structure

```

chapter4-first-app-deployment/
├── ui_approach/
│   └── nginx/
│       ├── nginx_deployment.yml
│       └── nginx_svc.yml
│
├── cli_approach/
│   └── apache/
│       ├── apache_deployment.yml
│       └── apache_svc.yml
│
└── declarative_approach/
    └── online_shop/
        └── online-shop-app.yml

```

---

##  Learning Paths

👉 Click below to explore each approach step by step:

1. [UI Approach (NGINX Example)](./ui_approach/nginx/README.md)  
   - Deploy app via ArgoCD Dashboard  
   - Good for beginners and demos  

2. [CLI Approach (Apache Example)](./cli_approach/apache/README.md)  
   - Deploy app via ArgoCD CLI (`argocd app create`)  
   - Good for admins and operators  

3. [Declarative Approach (Online Shop Example)](./declarative_approach/online_shop/README.md)  
   - Deploy app via **Application CRD (YAML in Git)**  
   - True GitOps → reproducible, auditable, production-ready  

---

##  Comparison: UI vs CLI vs Declarative Approaches

| Approach       | How App is Created | Where Config Lives | Best For | Limitations |
|----------------|-------------------|--------------------|----------|-------------|
| **UI** (NGINX) | Create app via **ArgoCD Dashboard** | In **Cluster only** | Quick demos, beginners | Not reproducible, not version-controlled |
| **CLI** (Apache) | `argocd app create ...` via **CLI** | In **Cluster only** | Operators, admins, testing | Still imperative, config not in Git |
| **Declarative** (Online Shop) | Apply **Application CRD YAML** | In **Git + Cluster** | Real GitOps, production, teams | Initial setup effort needed |

---

##  Key Takeaways

- **UI** → Fast & visual → great for learning, but **not GitOps**.  
- **CLI** → Scriptable & powerful → better than UI, but still **imperative**.  
- **Declarative** → Version-controlled & reproducible → the **true GitOps way** (what you’ll use in production).  

---

Happy Learning