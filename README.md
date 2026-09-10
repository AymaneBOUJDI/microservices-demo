
# 🛒 Online Boutique - Cloud Native Microservices Deployment on Azure (AKS & ACR)

Ce projet documente l'architecture, la conteneurisation, l'automatisation et le déploiement complet de l'application **Online Boutique** (Google Cloud Microservices Demo) sur **Azure Kubernetes Service (AKS)** avec **Azure Container Registry (ACR)**.

---

## 📐 Architecture & Infrastructure Cloud

L'application est composée de **11 microservices polyglottes** (Go, C#, Node.js, Python, Java) communicant via gRPC/REST, accompagnés d'un cache Redis :

* **Fournisseur Cloud :** Microsoft Azure
* **Groupe de Ressources :** `rg-aks-aymane-fresh`
* **Cluster Managed Kubernetes :** `aks-aymane-cluster` (2 Nœuds, Région: Poland Central)
* **Registre de Conteneurs Private :** `acraymanepresh100.azurecr.io` (ACR)
* **Point d'accès Web :** Service LoadBalancer (`frontend-external`) avec IP publique dédiée

---

## 🛠️ Étapes Réalisées & Déploiement

### 1. Conteneurisation & Publication des Images vers Azure ACR
Création d'un script d'automatisation Shell (`build_and_push.sh`) pour :
* Builder les images Docker des 11 microservices + l'image de cache `redis-cart`.
* Gérer la structure spécifique du microservice `.NET` (`cartservice`).
* Tagger l'ensemble des images sous la version `:v1` et les pusher sur l'ACR privé :

```bash
chmod +x build_and_push.sh
./build_and_push.sh

### 2. Adaptation des Manifestes Kubernetes

Mise à jour du fichier de manifeste global release/kubernetes-manifests.yaml pour modifier les registres source d'origine vers l'ACR privé :

    Remplacement des adresses d'images : acraymanepresh100.azurecr.io/<microservice>:v1

### 3. Redimensionnement du Cluster (Scaling AKS)

Afin de résoudre les contraintes d'allocation CPU (FailedScheduling) liées à l'exécution de 12 composants en simultané, le cluster AKS a été étendu à 2 nœuds :
#### Redimensionnement du cluster AKS
az aks scale --resource-group rg-aks-aymane-fresh --name aks-aymane-cluster --node-count 2

#### Application des configurations Kubernetes
kubectl apply -f release/kubernetes-manifests.yaml

## 📊 État et Déploiement des Microservices

Vérification avec kubectl get pods : 100 % des composants sont au statut 1/1 Running.

Service,Langage / Framework,Statut Kubernetes,Replicas
frontend,Go,Running,1/1
cartservice,C# (.NET),Running,1/1
productcatalogservice,Go,Running,1/1
currencyservice,Node.js,Running,1/1
paymentservice,Node.js,Running,1/1
shippingservice,Go,Running,1/1
emailservice,Python,Running,1/1
checkoutservice,Go,Running,1/1
recommendationservice,Python,Running,1/1
adservice,Java,Running,1/1
loadgenerator,Python / Locust,Running,1/1
redis-cart,Redis,Running,1/1

## 🔍 Validation, Supervision & Self-Healing

### 1.    Supervision des Logs Applicatifs : Suivi en temps réel des flux de traitement et paiements (checkoutservice / paymentservice) via kubectl logs -f.

### 2.    Test de Résilience (Self-Healing) :
#### Simulation d'une panne par suppression manuelle du Pod de paiement :

kubectl delete pod -l app=paymentservice

Résultat : Kubernetes a automatiquement reconstruit et relancé un nouveau Pod sain en 6 secondes, sans interruption de service.

## 🌐 Exposition de l'Application

#### Obtension de l'IP publique d'accès :

kubectl get service frontend-external
 
L'application e-commerce est directement accessible sur le port 80 depuis tout navigateur via http://<EXTERNAL-IP>.
EOF
