# Aplicaciones en Kubernetes

Esta carpeta contiene un ejemplo básico de una aplicación web desplegada en Kubernetes para simular una arquitectura empresarial real.

## Archivos incluidos

- deployment.yaml: define el Deployment con el contenedor de la API y recursos base.
- service.yaml: expone la aplicación dentro del cluster mediante un Service de tipo ClusterIP.
- hpa.yaml: habilita escalado automático de pods según uso de CPU.

## Uso

Aplicar los manifiestos con:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
```
