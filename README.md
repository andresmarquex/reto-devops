# 🚀 Platform & DevOps Engineer Challenge - 2026

Este repositorio contiene la solución completa, automatizada y documentada para el reto técnico de **Platform & DevOps Engineer**. Toda la infraestructura se ha diseñado bajo principios de alta disponibilidad, seguridad por capas (*DevSecOps*) y el modelo GitOps como fuente única de verdad.

---

## 🗺️ Mapa de Referencia del Reto (Trazabilidad)

Para facilitar la revisión técnica, aquí se mapea cada punto del requerimiento con su implementación en este repositorio:

| Punto del Reto | Componente / Solución Implementada | Ubicación en el Repositorio |
| :--- | :--- | :--- |
| **1. Administración** | Arquitectura Multi-AZ y Automatización Mixta | `/terraform/main.tf` y `/ansible/site.yml` |
| **2. Servicios de Red** | Segmentación VPC (Públicas/Privadas) y Script de Latencia | `/terraform/main.tf` y `/scripts/network_diagnostic.sh` |
| **3. Contenedores** | Configuración de Microservicios en Kubernetes | `/kubernetes/apps/` |
| **4. Ciberseguridad** | Hardening de Firewalls (UFW/Windows) y Escaneo de Vulnerabilidades | `/ansible/roles/hardening_ufw/` y `.github/workflows/ci-cd.yml` |
| **5. Gestión de Nube** | Base de datos Amazon RDS Multi-AZ y Gobernanza | `/terraform/main.tf` y `/kubernetes/argocd/` |
| **6. Soporte 24/7** | Simulación de Incidente Crítico, Línea de Tiempo y Postmortem ITIL | `/docs/postmortem.md` |
| **7. Arquitectura** | Diagramas de Arquitectura (Cloud IaaS/PaaS, On-premise) | `/docs/arquitectura.md` |
| **9. Automatización** | Infraestructura como Código (IaC) reproducible | `/terraform/` |
| **10. Monitoreo** | Escalado Horizontal Automático (HPA) por métricas | `/kubernetes/apps/hpa.yaml` |
| **11. Buenas Prácticas CI/CD** | Pipeline DevSecOps y Declaración de Aplicación GitOps | `.github/workflows/ci-cd.yml` y `/kubernetes/argocd/` |
| **12. Documentación** | Justificación de Gestión de Configuración y Control de Cambios | `/docs/control-cambios.md` |

---

## 🏛️ Decisiones de Arquitectura Clave

1. **Seguridad Perimetral e Identidades:** Uso estricto del *Principio de Mínimo Privilegio*. Las instancias EC2 y bases de datos RDS están aisladas en subredes privadas sin IP pública. El tráfico entrante se filtra a nivel de red con NACLs y a nivel de recurso mediante *Security Groups* interconectados.
2. **Infraestructura Elástica:** Se implementó un *Horizontal Pod Autoscaler* (HPA) en Kubernetes para responder automáticamente a ráfagas de tráfico según el uso de CPU y memoria, optimizando costos operativos.
3. **GitOps (ArgoCD):** Se elimina el acceso imperativo al clúster. El pipeline de CI (GitHub Actions) actualiza el tag de la imagen en Git, y ArgoCD se encarga de reconciliar el estado en el clúster de AWS, mitigando el *configuration drift*.

---

## 🛠️ Instrucciones de Despliegue Rápido

### 1. Aprovisionamiento de Cloud (IaC)
```bash
cd terraform/
terraform init
terraform plan -out=deploy.tfplan
terraform apply "deploy.tfplan"
