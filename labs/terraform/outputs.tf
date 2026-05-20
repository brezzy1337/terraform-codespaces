output "development_repo" {
  description = "The name of the development repo"
  value       = github_repository.repo_foreach["development"].name
}

output "production_repo" {
  description = "The name of the production repo"
  value       = github_repository.repo_foreach["production"].name
}

output "current_user" {
  description = "Current GitHub user name"
  value       = data.github_user.current.name
}

output "development_repo_url" {
  description = "URL of the development repository"
  value       = github_repository.repo_foreach["development"].html_url
}

output "production_repo_url" {
  description = "URL of the production repository"
  value       = github_repository.repo_foreach["production"].html_url
}

output "production_environment" {
  description = "Production environment name"
  value       = github_repository_environment.production.environment
}
