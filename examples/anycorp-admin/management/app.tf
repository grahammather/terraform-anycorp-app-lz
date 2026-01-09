# prereqs
data "tfe_organizations" "this" {}

data "tfe_organization" "this" {
  name = data.tfe_organizations.this.names[0]

  lifecycle {
    precondition {
      condition     = length(data.tfe_organizations.this.names) == 1
      error_message = "Expected exactly one TFE organization for this token, but found ${length(data.tfe_organizations.this.names)}."
    }
  }
}

data "tfe_project" "admin_project" {
  name = local.tfe_admin_project
  organization = data.tfe_organization.this.name
}

data "tfe_variable_set" "vault" {
  name = "Vault Varset - ${data.tfe_project.admin_project.name}"
  organization = data.tfe_organization.this.name
}

module "anycorp-app-lz" {
  source  = "./../../.."
  # insert required variables here

  app_name = var.app_name
  environments = var.environments

  # sensible defaults/static config
  vault_jwt_auth_path = "jwt"
  tfe_variable_set_vault_id = data.tfe_variable_set.vault.id
}