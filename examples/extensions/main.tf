module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      int = { cidr = ["10.18.1.0/24"] }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
  }
}

module "vm" {
  source  = "cloudnationhq/vmss/azure"
  version = "~> 0.1"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  vm = {
    type          = "linux"
    name          = module.naming.linux_virtual_machine.name
    resourcegroup = module.rg.groups.demo.name
    location      = module.rg.groups.demo.location
    extensions    = local.exts

    interfaces = {
      int = {
        subnet = module.network.subnets.int.id
      }
    }
  }
}