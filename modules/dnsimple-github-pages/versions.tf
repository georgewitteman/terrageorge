terraform {
  required_providers {
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "~> 0.5"
    }
  }
  required_version = ">= 1"
}
