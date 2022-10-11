resource "aws_iam_instance_profile" "vault" {
  name_prefix = "${var.resource_name_prefix}-vault"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.resource_name_prefix}-vault"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloud_auto_join" {
  name   = "${var.resource_name_prefix}-vault-auto-join"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.cloud_auto_join.json
}

data "aws_iam_policy_document" "cloud_auto_join" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "auto_unseal" {
  name   = "${var.resource_name_prefix}-vault-auto-unseal"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_unseal.json
}

data "aws_iam_policy_document" "auto_unseal" {
  statement {
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [aws_kms_key.this.arn]
  }
}

resource "aws_iam_role_policy" "session_manager" {
  name   = "${var.resource_name_prefix}-vault-ssm"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.session_manager.json
}

data "aws_iam_policy_document" "session_manager" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "secrets_manager" {
  name   = "${var.resource_name_prefix}-vault-secrets-manager"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.secrets_manager.json
}

data "aws_iam_policy_document" "secrets_manager" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [aws_secretsmanager_secret.tls.arn]
  }
}
