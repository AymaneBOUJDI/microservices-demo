# 🚀 Azure AKS Cloud-Native Microservices Platform

![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=Helm&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)

Déploiement automatisé End-to-End d'une application e-commerce distribuée (11 microservices polyglottes : Go, Node.js, Python, Java, C#) sur **Azure Kubernetes Service (AKS)** avec **Terraform**, pipelines **CI/CD Docker**, et observabilité complète via **Prometheus & Grafana**.

---

## 📐 Architecture Globale

```text
[ Developer Machine ] 
       │
       ├──► 1. IaC Provisioning (Terraform) ──────► [ Azure Infrastructure ]
       │                                              ├── Resource Group
       ├──► 2. Build & Packaging (CI/CD Script) ───►  ├── Azure Container Registry (ACR)
       │                                              └── Azure Kubernetes Service (AKS)
       └──► 3. Monitoring & CD (Helm) ────────────►       ├── Namespaces (default / monitoring)
                                                          └── Public Load Balancers (Grafana)
```
# 🛠️ Stack Technique & Outils

  .  Infrastructure as Code : HashiCorp Terraform (AzureRM Provider)

  .  Cloud Provider : Microsoft Azure (AKS, ACR, Virtual Networks, Load Balancer)

  .  Conteneurisation : Docker (Multi-stage builds) & Azure Container Registry

  .  Orchestration : Kubernetes (v1.28+)

  .  Gestionnaire de Paquets K8s : Helm v3

  .  Observabilité : Prometheus, Grafana, Node Exporter, Kube-State-Metrics

# 🔄 Description des Pipelines d'Automation
## 1. Provisioning d'Infrastructure (IaC - Terraform)

  .  Automation du déploiement du Groupe de Ressources (rg-aks-aymane-fresh), d'Azure Container Registry (acraymanepresh100) et du Cluster AKS (aks-aymane-cluster).


  .  Configuration native de la liaison d'autorisation IAM/RBAC (AksPull) permettant à AKS d'extraire les images depuis ACR de manière sécurisée.

```bash
cd terraform/
terraform init
terraform plan
terraform apply --auto-approve
```
## 2. CI/CD Build & Container Registry Push

  .  Pipeline Bash automatisé (build_and_push.sh) gérant la compilation multi-stage, le contexte particulier pour .NET 8.0 (cartservice) et la couche de cache (redis-cart).

  .  Stratégie de marquage double : Tag :latest pour le déploiement continu et :COMMIT_HASH pour la traçabilité en registre.

```bash
chmod +x build_and_push.sh
./build_and_push.sh

```    
## 3. Orchestration & Résolution de Pannes K8s

  .  Gestion du goulot d'étranglement CPU : Analyse et diagnostic d'un blocage de pods à l'état Pending lié aux requests.cpu cumulées (>2.2 Cores).

  .  Auto-scaling Infrastructure : Scalabilité horizontale de l'Agent Pool AKS de 1 à 2 Nœuds Workers via Azure CLI, rétablissant 100% des Pods à l'état 1/1 Running.

```bash
az aks scale \
  --resource-group rg-aks-aymane-fresh \
  --name aks-aymane-cluster \
  --node-count 2 \
  --nodepool-name nodepool1
```

## 4. Observabilité & Monitoring (Helm Stack)

  .  Déploiement automatisé de la chart kube-prometheus-stack dans le namespace isolé monitoring.

  .  Exposition publique de l'interface Grafana via Azure Public Load Balancer pour le suivi en temps réel des métriques système et applicatives (Golden Signals).

```bash
kubectl create namespace monitoring
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=LoadBalancer
```

# ⚡ Test de Résilience (Chaos Engineering)

Afin de valider les fonctionnalités d'auto-guérison (Self-Healing) de Kubernetes, une suppression forcée du pod de paiement a été simulée :
```bash

kubectl delete pod -l app=paymentservice --grace-period=0 --force

```
### Résultat : Re-création automatique du pod par le controller K8s et réintégration au Load Balancer valides en 5.8 secondes, sans interruption du tunnel de commande.

# 🧹 Nettoyage des Ressources (Fin de Projet)

Pour stopper la facturation des ressources statiques sur Azure (Disques SSD, IP Publiques) :

```bash

az group delete --name rg-aks-aymane-fresh --yes --no-wait
```

# 👨‍💻 Auteur

## Aymane BOUJDI

### Ingénieur Cloud & DevOps

    LinkedIn (https://www.linkedin.com/in/aymane-boujdi-45587427b/)
