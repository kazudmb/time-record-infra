variable "enable_github_oidc" {
  description = "Whether to create GitHub OIDC resources"
  type        = bool
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN"
  type        = string
  default     = null
}

variable "github_oidc_thumbprints" {
  description = "List of thumbprints for the GitHub OIDC provider"
  type        = list(string)
}

variable "github_owner" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repo_infra" {
  description = "GitHub repository name"
  type        = string
}

variable "github_repo_backend" {
  description = "GitHub repository name for backend"
  type        = string
}

variable "github_repo_frontend" {
  description = "GitHub repository name for frontend"
  type        = string
}

variable "backend_role_name" {
  description = "IAM role name for backend GitHub Actions"
  type        = string
  default     = null
}

variable "backend_inline_policy_json" {
  description = "Inline policy JSON for backend GitHub Actions role"
  type        = string
  default     = null
}

variable "frontend_role_name" {
  description = "IAM role name for frontend GitHub Actions"
  type        = string
  default     = null
}

variable "frontend_inline_policy_json" {
  description = "Inline policy JSON for frontend GitHub Actions role"
  type        = string
  default     = null
}

variable "infra_role_name" {
  description = "IAM role name for infra GitHub Actions"
  type        = string
}
