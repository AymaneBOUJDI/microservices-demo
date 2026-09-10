#!/bin/bash
REGISTRY="acraymanepresh100.azurecr.io"
TAG="v1"

services=(
  "checkoutservice"
  "recommendationservice"
  "frontend"
  "paymentservice"
  "productcatalogservice"
  "cartservice"
  "loadgenerator"
  "currencyservice"
  "shippingservice"
  "adservice"
)

for service in "${services[@]}"; do
  echo "----------------------------------------------------"
  echo "Building and pushing $service..."
  echo "----------------------------------------------------"
  docker build -t "$REGISTRY/$service:$TAG" "./src/$service"
  docker push "$REGISTRY/$service:$TAG"
done

echo "Toutes les images ont été envoyées avec succès sur l'ACR!"
