provider "aws" {
    region = "us-east-1"

    default_tags {
        tags = {
            Environment = "Lab"
            Project = "Node-Auth-API"
            ManagedBy = "Terraform"
        }
    }
}

