data "github_user" "current" {
  username = ""
}

locals {
  repo_features = {
    has_issues      = true
    has_wiki        = true
    has_discussions = true
    has_projects    = true
    auto_init       = true
  }

  merge_settings = {
    allow_merge_commit     = true
    allow_rebase_merge     = true
    allow_squash_merge     = true
    delete_branch_on_merge = true
  }

  managed_by = "Managed by Terraform (${data.github_user.current.login})"
}

# For_each CI/CD
resource "github_repository" "repo_foreach" {
  for_each    = var.repositories
  name        = "repo-${each.key}"
  description = each.value
  visibility  = "public"
  auto_init   = true

  topics = ["terraform", "foreach", "example"]
}

resource "github_branch_protection" "protection_development" {
  for_each      = var.branch_patterns
  repository_id = github_repository.repo_foreach["development"].node_id
  pattern       = each.key

  allows_deletions                = true
  allows_force_pushes             = true
  require_conversation_resolution = false
}

resource "github_branch_protection" "protection_staging" {
  for_each      = var.branch_patterns
  repository_id = github_repository.repo_foreach["staging"].node_id
  pattern       = each.key

  allows_deletions                = true
  allows_force_pushes             = true
  require_conversation_resolution = false
}

resource "github_branch_protection" "protection_production" {
  for_each      = var.branch_patterns
  repository_id = github_repository.repo_foreach["production"].node_id
  pattern       = each.key

  allows_deletions                = false
  allows_force_pushes             = false
  require_conversation_resolution = false

  enforce_admins         = true
  require_signed_commits = true

  required_pull_request_reviews {
    required_approving_review_count = var.prod_branch_protection
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }
}

resource "github_issue_label" "label_development" {
  for_each    = var.label_config
  repository  = github_repository.repo_foreach["development"].name
  name        = each.key
  color       = each.value
  description = "${each.key} label for API repository"
}

resource "github_issue_label" "label_staging" {
  for_each    = var.label_config
  repository  = github_repository.repo_foreach["staging"].name
  name        = each.key
  color       = each.value
  description = "${each.key} label for API repository"
}

resource "github_issue_label" "label_production" {
  for_each    = var.label_config
  repository  = github_repository.repo_foreach["production"].name
  name        = each.key
  color       = each.value
  description = "${each.key} label for API repository"
}

resource "github_repository_environment" "production" {
  repository  = github_repository.repo_foreach["production"].name
  environment = "production"

  reviewers {
    users = [data.github_user.current.id]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_repository_file" "production_readme" {
  repository          = github_repository.repo_foreach["development"].name
  branch              = "main"
  file                = "README.md"
  content             = <<-EOT
    # Production Repository

    This repository is managed by Terraform.

    ## Related Repositories

    - Development: [${github_repository.repo_foreach["development"].name}](${github_repository.repo_foreach["development"].html_url})
    - Production: [${github_repository.repo_foreach["production"].name}](${github_repository.repo_foreach["production"].html_url})
  EOT
  commit_message      = "Add README via Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@course.com"
  overwrite_on_create = true
}