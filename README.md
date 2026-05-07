# Alumno
- Rodrigo Alexander Baldeon Julca

---
### Configurar AWS CLI

```bash
aws configure
# AWS Access Key ID: <tu-access-key>
# AWS Secret Access Key: <tu-secret-key>
# Default region name: us-east-1
# Default output format: json
```

---

## Despliegue

### 1. Clonar el repositorio

```bash
git clone https://github.com/B4ld3m/iac2.git
cd iac2/aws
git checkout development
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Crear los workspaces

```bash
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod
```

### 4. Desplegar en DEV

```bash
terraform workspace select dev
terraform apply -auto-approve
```

### 5. Desplegar en QA

```bash
terraform workspace select qa
terraform apply -auto-approve
```

### 6. Desplegar en PROD

```bash
terraform workspace select prod
terraform apply -auto-approve
```

## 7. Destruir recursos

Para evitar costos, destruir los recursos en orden (PROD → QA → DEV):

```bash
terraform workspace select prod
terraform destroy -auto-approve

terraform workspace select qa
terraform destroy -auto-approve

terraform workspace select dev
terraform destroy -auto-approve
```

---

## Autores

Proyecto desarrollado para el curso de Infraestructura como Código — 2026.

- Cuenta AWS: `249954438132`
- Región: `us-east-1`
- Repositorio: [github.com/B4ld3m/iac2](https://github.com/B4ld3m/iac2/tree/development)
- Branch: `development`