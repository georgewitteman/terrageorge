plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.17.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  deep_check = true
}