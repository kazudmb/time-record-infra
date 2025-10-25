import {
  to = module.github_oidc.aws_iam_role.gha_ci[0]
  id = local.gha_role_name
}

import {
  to = module.github_oidc.aws_iam_role_policy_attachment.gha_admin[0]
  id = "${local.gha_role_name}/arn:aws:iam::aws:policy/AdministratorAccess"
}
