# Backend
resource "docker_container" "api" {
  name  = "api-${terraform.workspace}"
  image = "lab/api"

  ports {
    internal = "3000"
    external = var.api_port[terraform.workspace]
  }

  networks_advanced {
    name = docker_network.private_network.name
  }
}

# Frontend
resource "docker_container" "web" {
  name  = "web-${terraform.workspace}"
  image = "lab/web"

  ports {
    internal = "80"
    external = var.web_port[terraform.workspace]
  }

  networks_advanced {
    name = docker_network.private_network.name
  }
}

# Base de datos
resource "docker_container" "bd" {
  name  = "bd-${terraform.workspace}"
  image = "postgres"
  env = ["POSTGRES_PASSWORD=secret"]

  ports {
    internal = "5432"
    external = var.bd_port[terraform.workspace]
  }

  networks_advanced {
    name = docker_network.private_network.name
  }
}
# Network
resource "docker_network" "private_network" {
  name = "${terraform.workspace}_network"
}