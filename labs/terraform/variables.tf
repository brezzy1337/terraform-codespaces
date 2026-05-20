variable "repo_names" {
  description = "Names for repositories"
  type        = list(string)
  default     = ["repo-1", "repo-2", "repo-3"]
}

variable "repositories" {
  description = "Map of repository configurations"
  type        = map(string)
  default = {
    "development" = "Development Repository"
    "staging"     = "Staging Repository"
    "production"  = "Production Repository"
  }
}

variable "branch_patterns" {
  description = "Map of branch patterns to protect"
  type        = map(string)
  default = {
    "main"    = "Main branch"
    "release" = "Release branch"
  }
}

variable "label_config" {
  description = "Map of lab configurations"
  type        = map(string)
  default = {
    "bug"     = "FF0000"
    "feature" = "00FF00"
    "docs"    = "0000FF"
    "test"    = "FFFF00"
  }
}

variable "repo_files" {
  description = "Map of repository files"
  type        = map(string)
  default = {
    ".gitignore"      = "**/*.tfstate"
    "README.md"       = "# Repository README\n this is a sample repository."
    "CONTRIBUTING.md" = "# Contributing Guidelines\nHow to contribute to this project."
    "LICENSE"         = "MIT License\nCopyright (c) 2023"
  }

}

variable "repository_visibility" {
  description = "Visibility of the repository"
  type        = string
  default     = "public"
}

variable "environment" {
  description = "Environment tag for the repository"
  type        = string
  default     = "learning-terraform"
}

variable "repository_features" {
  description = "Enabled features for the repository"
  type = object({
    has_issues      = bool
    has_discussions = bool
    has_wiki        = bool
  })
  default = {
    has_issues      = true
    has_discussions = true
    has_wiki        = false
  }
}

variable "dev_repository_name" {
  description = "Name of the Dev Github Repository"
  type        = string
  default     = "development-repo"
}

variable "dev_repo_issues" {
  description = "Dev repo issues settings"
  type        = bool
  default     = true
}

variable "dev_discussions" {
  description = "Dev repo discussions settings"
  type        = bool
  default     = true
}

variable "dev_wiki" {
  description = "Dev repo wiki settings"
  type        = bool
  default     = true
}

variable "prod_repository_name" {
  description = "Name of the Production GitHub repository"
  type        = string
  default     = "production-repo"
}

variable "prod_branch_protection" {
  description = "Number of required approvals for production branch"
  type        = number
  default     = 2
}