## INSTALL AZURE CLI

    -    sudo apt update
    -    sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
    -    curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    -    sudo apt update
    -    sudo apt-get install azure-cli
    -    az --version

## Azure Login
    -    az login
    -    Enter the credentials in browser with the code
    -    az account show
    -    az resource group list
## Code Explanation

1️⃣ Provider Block
h
Copy
Edit
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
azurerm: Specifies that we are using Azure as the provider.

skip_provider_registration = true: This disables automatic registration of Azure Resource Providers, which is required if you lack permissions (like in cloud labs or restricted environments).
🔹 What is Provider Registration in Azure?
Provider Registration in Azure is the process of enabling Resource Providers that allow Terraform (or any infrastructure management tool) to create and manage specific Azure resources.

🔸 What are Resource Providers?
Azure organizes its services into Resource Providers, each responsible for managing a specific category of resources.

Example Resource Providers
Resource Provider	Manages
Microsoft.Compute	Virtual Machines (VMs), Disks
Microsoft.Storage	Storage Accounts, Blobs
Microsoft.Network	Virtual Networks (VNet), Load Balancers
Microsoft.ContainerInstance	Azure Container Instances (ACI)
Microsoft.Web	App Services, Web Apps
🔸 Why Do We Need Provider Registration?
Before you create resources using Terraform, Azure requires that the related Resource Provider is registered in your Azure Subscription.

🔸 How Does Registration Work?
When you create an Azure subscription, some common providers (like Microsoft.Compute for VMs) are automatically registered.

If you try to deploy a resource from an unregistered provider, Terraform (or Azure CLI) will fail unless the provider is registered.

Terraform automatically registers missing providers unless you disable it using:

hcl
Copy
Edit
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

2️⃣ Data Block: Fetching Resource Group Info
hcl
Copy
Edit
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}
Uses data source to fetch details of an existing Azure Resource Group (var.resource_group_name).

This ensures that resources are deployed in the correct region.

3️⃣ Resource Block: Deploying Azure Container Instance (ACI)
hcl
Copy
Edit
resource "azurerm_container_group" "main" {
  name                = "${var.prefix}-container-group"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-container-group"
  os_type             = "Linux"
Creates an Azure Container Instance.

Uses a public IP (ip_address_type = "Public") and a DNS name (dns_name_label).

Runs a Linux-based container.

4️⃣ Container Configuration
hcl
Copy
Edit
container {
  name   = "hello-world"
  image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
  cpu    = "0.5"
  memory = "1.5"
  ports {
    port     = 80
    protocol = "TCP"
  }
}
Deploys a container named "hello-world" using the image mcr.microsoft.com/azuredocs/aci-helloworld.

Assigns 0.5 vCPU and 1.5GB RAM.

Opens port 80 for HTTP access.

5️⃣ Output: Display the DNS Name
hcl
Copy
Edit
output "dns_hostname" {
  value = azurerm_container_group.main.fqdn
}
Outputs the FQDN (fully qualified domain name) of the container instance.

🔄 Equivalent in AWS (ECS Fargate)
In AWS, this setup is similar to AWS Fargate (ECS) with a Public IP. Below is how you'd do the same in AWS:

1️⃣ Provider Block
hcl
Copy
Edit
provider "aws" {
  region = "us-east-1"
}
2️⃣ Data Source: Fetch Existing VPC
hcl
Copy
Edit
data "aws_vpc" "default" {
  default = true
}
3️⃣ Create an ECS Cluster
hcl
Copy
Edit
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-ecs-cluster"
}
4️⃣ Create ECS Task Definition
hcl
Copy
Edit
resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name  = "hello-world"
      image = "public.ecr.aws/docker/library/nginx:latest"
      cpu   = 512
      memory = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}
Defines a Fargate Task that runs an Nginx container.

5️⃣ Create an ECS Service
hcl
Copy
Edit
resource "aws_ecs_service" "main" {
  name            = "${var.prefix}-ecs-service"
  cluster        = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  launch_type    = "FARGATE"

  network_configuration {
    subnets          = data.aws_vpc.default.subnets
    assign_public_ip = true
  }
}
Runs the ECS service on Fargate with a public IP.

6️⃣ Output Public DNS Name
hcl
Copy
Edit
output "service_url" {
  value = aws_ecs_service.main.id
}
