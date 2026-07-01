# 🔄 Despliegue Continuo con ArgoCD (Modelo GitOps)

Esta carpeta contiene la configuración declarativa para la automatización del despliegue en el clúster mediante ArgoCD, eliminando la necesidad de accesos imperativos directos (`kubectl apply`) desde máquinas externas.

## Conceptos Clave Implementados:
* **Automated Sync:** Al habilitar `prune` y `selfHeal`, Git se convierte en la **Única Fuente de Verdad**. Cualquier cambio manual no autorizado (*configuration drift*) en el clúster será sobrescrito automáticamente por ArgoCD para coincidir con Git.
* **AppProject Isolation:** Se implementan controles de acceso perimetrales dentro del clúster para mitigar movimientos laterales en caso de un incidente de seguridad.

## Despliegue Inicial de la Automatización:
Una vez instalado ArgoCD en el clúster, aplique este manifiesto para iniciar la sincronización:

```bash
kubectl apply -f project.yaml
kubectl apply -f application.yaml
```
