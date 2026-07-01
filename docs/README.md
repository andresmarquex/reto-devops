# 🏛️ Diseños de Arquitectura de Infraestructura

Este documento detalla los flujos y la topología de red diseñados para garantizar la alta disponibilidad, escalabilidad y aislamiento de los microservicios.

## 1. Arquitectura Cloud (IaaS / PaaS en AWS)
La arquitectura utiliza una VPC segmentada en tres capas a lo largo de múltiples Zonas de Disponibilidad (Multi-AZ). La capa de cómputo está orquestada por Amazon EKS (Kubernetes) y la capa de datos utiliza Amazon RDS redundante.

```mermaid
graph TD
    User([🌐 Usuarios de la App]) -->|HTTPS:443| ALB[⚖️ Application Load Balancer]
    
    subgraph VPC [Amazon VPC - 10.0.0.0/16]
        subgraph Public_Subnets [Subnets Públicas - Capa de Ruteo]
            ALB
            NAT[Gateway NAT]
        end

        subgraph Private_Subnets_App [Subnets Privadas - Capa de Cómputo]
            subgraph EKS_Cluster [Clúster Amazon EKS]
                Pod1[📦 Microservicio Pod A - AZ1]
                Pod2[📦 Microservicio Pod B - AZ2]
            end
        end

        subgraph Private_Subnets_Data [Subnets Privadas - Capa de Datos]
            RDS_Master[(🗄️ RDS Master - AZ1)] --- RDS_Replica[(🗄️ RDS Read Replica - AZ2)]
        end
    end

    ALB -->|Reenvía Tráfico TCP/HTTP| Pod1
    ALB -->|Reenvía Tráfico TCP/HTTP| Pod2
    Pod1 -->|Escribe/Lee:5432| RDS_Master
    Pod2 -->|Escribe/Lee:5432| RDS_Master
    NAT -->|Salida segura a Internet| EKS_Cluster