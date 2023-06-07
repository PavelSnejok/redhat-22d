module "iam-roles-dev" {
    count = var.stage == "dev" ? 1 : 0
    source = "./modules/dev"
    devops_role = var.devops_role
    devops_policy = var.devops_policy
}

module "iam-roles-prod" {
    count = var.stage == "prod" ? 1 : 0
    source = "./modules/prod"
    devops_role = var.devops_role
    devops_policy = var.devops_policy
}