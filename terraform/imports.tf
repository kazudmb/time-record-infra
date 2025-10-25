import {
  to = module.backend.module.iam.aws_iam_role.lambda_role
  id = "${local.project}-lambda-role"
}

import {
  to = module.backend.module.iam.aws_iam_policy.ddb_rw
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.project}-ddb-rw"
}

import {
  to = module.github_oidc.aws_iam_role.gha_ci[0]
  id = local.gha_role_name
}

import {
  to = module.github_oidc.aws_iam_role_policy_attachment.gha_admin[0]
  id = "${local.gha_role_name}/arn:aws:iam::aws:policy/AdministratorAccess"
}
