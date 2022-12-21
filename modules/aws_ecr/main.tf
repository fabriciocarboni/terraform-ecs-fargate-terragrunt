/*
 * main.tf
 * Creates a Amazon Elastic Container Registry (ECR) for the application
 */

resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "REPOSITORY_URL" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.ecr_repo.repository_url
}

# it comes from aws_ecr/terragrunt.hcl inputs repository_name
variable "repository_name" {}