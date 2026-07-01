# reto-devops

Estructura base del repositorio para un proyecto DevOps con CI/CD, infraestructura como código, automatización y despliegue.

## Estructura propuesta

- .github/workflows/ - Pipelines de CI/CD con GitHub Actions
- terraform/ - Infraestructura como Código (VPC, EC2, RDS, ALB, EKS/K8s)
- ansible/ - Configuración de servidores y automatización
- kubernetes/ - Manifiestos de la aplicación y configuración de ArgoCD
- scripts/ - Scripts de automatización
- docs/ - Diagramas y documentación de soporte

## Archivos creados

- [terraform/main.tf](terraform/main.tf)
- [terraform/variables.tf](terraform/variables.tf)
- [terraform/outputs.tf](terraform/outputs.tf)
- [ansible/playbooks/site.yml](ansible/playbooks/site.yml)
- [kubernetes/apps/README.md](kubernetes/apps/README.md)
- [kubernetes/argocd/README.md](kubernetes/argocd/README.md)
- [scripts/README.md](scripts/README.md)
- [docs/README.md](docs/README.md)

## 🏗️ Infraestructura como Código (IaC) con Terraform

Toda la topología de red y los servicios de cómputo y datos en AWS se gestionan de forma declarativa.

### Estructura de aislamiento implementada

1. Capa perimetral (pública): aloja exclusivamente el ALB público.
2. Capa de aplicación (privada): servidores EC2 aislados del direccionamiento público.
3. Capa de persistencia (privada, Multi-AZ): RDS PostgreSQL configurado para failover automático.

### Instrucciones de despliegue

Asegúrese de exportar sus credenciales de AWS y ejecute:

```bash
cd terraform/
terraform init
terraform validate
terraform plan -out=deploy.tfplan
terraform apply "deploy.tfplan"
```
