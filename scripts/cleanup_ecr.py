#!/usr/bin/env python3
# cleanup_ecr.py - Automatización de limpieza de recursos en AWS ECR
import boto3
import sys

def cleanup_untagged_images(repository_name, region="us-east-1"):
    print(f"📦 Conectando a AWS ECR en la región {region}...")
    client = boto3.client('ecr', region_name=region)
    
    try:
        # Listar imágenes del repositorio
        response = client.describe_images(repositoryName=repository_name, filter={'tagStatus': 'UNTAGGED'})
        images_to_delete = response.get('imageDetails', [])
        
        if not images_to_delete:
            print("✅ No se encontraron imágenes huérfanas (untagged). El repositorio está optimizado.")
            return

        # Estructurar identificadores para la eliminación
        image_ids = [{'imageDigest': img['imageDigest']} for img in images_to_delete]
        print(f"⚠️ Se encontraron {len(image_ids)} imágenes sin etiqueta listas para ser depuradas.")
        
        # Eliminar imágenes
        delete_response = client.batch_delete_image(repositoryName=repository_name, imageIds=image_ids)
        
        for deleted in delete_response.get('imageIds', []):
            print(f"🗑️ Imagen eliminada con éxito (Digest): {deleted['imageDigest'][:20]}...")
            
    except client.exceptions.RepositoryNotFoundException:
        print(f"❌ Error: El repositorio '{repository_name}' no existe.")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error inesperado: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    # Nombre del repositorio de ejemplo para el reto
    REPO = "mi-microservicio-app"
    cleanup_untagged_images(REPO)