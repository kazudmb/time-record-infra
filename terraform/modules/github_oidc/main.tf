locals {
  oidc_enabled = var.enable_github_oidc
}

resource "aws_iam_openid_connect_provider" "github" {
  count = local.oidc_enabled && var.existing_github_oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

locals {
  provider_arn = coalesce(
    var.existing_github_oidc_provider_arn,
    try(aws_iam_openid_connect_provider.github[0].arn, null)
  )
  infra_repo_subs = [
    "repo:${var.github_owner}/${var.github_repo_infra}:ref:refs/heads/*",
    "repo:${var.github_owner}/${var.github_repo_infra}:ref:refs/tags/*",
    "repo:${var.github_owner}/${var.github_repo_infra}:pull_request",
    "repo:${var.github_owner}/${var.github_repo_infra}:environment:*"
  ]
  backend_repo  = trimspace(coalesce(var.github_repo_backend, ""))
  frontend_repo = trimspace(coalesce(var.github_repo_frontend, ""))
  backend_repo_subs = local.backend_repo != "" ? [
    "repo:${var.github_owner}/${local.backend_repo}:ref:refs/heads/*",
    "repo:${var.github_owner}/${local.backend_repo}:ref:refs/tags/*",
    "repo:${var.github_owner}/${local.backend_repo}:pull_request",
    "repo:${var.github_owner}/${local.backend_repo}:environment:*"
  ] : []
  frontend_repo_subs = local.frontend_repo != "" ? [
    "repo:${var.github_owner}/${local.frontend_repo}:ref:refs/heads/*",
    "repo:${var.github_owner}/${local.frontend_repo}:ref:refs/tags/*",
    "repo:${var.github_owner}/${local.frontend_repo}:pull_request",
    "repo:${var.github_owner}/${local.frontend_repo}:environment:*"
  ] : []
  create_backend_role  = local.oidc_enabled && var.backend_role_name != null && var.backend_inline_policy_json != null && length(local.backend_repo_subs) > 0
  create_frontend_role = local.oidc_enabled && var.frontend_role_name != null && var.frontend_inline_policy_json != null && length(local.frontend_repo_subs) > 0
}

data "aws_iam_policy_document" "gha_assume_infra" {
  count = local.oidc_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.infra_repo_subs
    }
  }
}

data "aws_iam_policy_document" "gha_assume_backend" {
  count = local.create_backend_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.backend_repo_subs
    }
  }
}

data "aws_iam_policy_document" "gha_assume_frontend" {
  count = local.create_frontend_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.frontend_repo_subs
    }
  }
}

resource "aws_iam_role" "gha_infra" {
  count              = local.oidc_enabled ? 1 : 0
  name               = var.infra_role_name
  assume_role_policy = data.aws_iam_policy_document.gha_assume_infra[0].json
  description        = "CI role assumed by GitHub Actions via OIDC"
}

resource "aws_iam_role_policy_attachment" "gha_admin" {
  count      = local.oidc_enabled ? 1 : 0
  role       = aws_iam_role.gha_infra[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "gha_backend" {
  count              = local.create_backend_role ? 1 : 0
  name               = var.backend_role_name
  assume_role_policy = data.aws_iam_policy_document.gha_assume_backend[0].json
  description        = "Backend deploy role assumed by GitHub Actions via OIDC"
}

resource "aws_iam_role_policy" "gha_backend_inline" {
  count  = local.create_backend_role ? 1 : 0
  name   = "backend-inline-policy"
  role   = aws_iam_role.gha_backend[0].name
  policy = var.backend_inline_policy_json
}

resource "aws_iam_role" "gha_frontend" {
  count              = local.create_frontend_role ? 1 : 0
  name               = var.frontend_role_name
  assume_role_policy = data.aws_iam_policy_document.gha_assume_frontend[0].json
  description        = "Frontend deploy role assumed by GitHub Actions via OIDC"
}

resource "aws_iam_role_policy" "gha_frontend_inline" {
  count  = local.create_frontend_role ? 1 : 0
  name   = "frontend-inline-policy"
  role   = aws_iam_role.gha_frontend[0].name
  policy = var.frontend_inline_policy_json
}
