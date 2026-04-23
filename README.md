# Alumno
- Rodrigo Alexander Baldeon Julca

### Clonar el repositorio
```
git clone https://github.com/B4ld3m/iac2
cd iac2
```

### Construir imágenes
```
# Imagen del backend
docker build -t lab/api -f src/api/Dockerfile src/api

# Imagen del frontend
docker build -t lab/web -f src/web01/Dockerfile src/web01
```

### Ver imágenes construidas
```
docker images
```

### Workspaces de Terraform
```
# Ver workspaces disponibles
terraform workspace list

# Crear un workspace nuevo
terraform workspace new dev

# Seleccionar un workspace
terraform workspace select dev

# Ver el workspace actual
terraform workspace show
```

### Levantar la infraestructura
```
terraform init
terraform plan
terraform apply
```

### Destruir la infraestructura
```
terraform destroy
```

### Subir cambios a GitHub
```
git add .
git commit -m "mensaje"
git push
```