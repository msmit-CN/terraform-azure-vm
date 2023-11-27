This section outlines the configuration of multiple network interfaces, enabling advanced networking capabilities and increased connectivity options.

```hcl
module "vm" {
  source  = "cloudnationhq/vmss/azure"
  version = "~> 0.1"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  vm = {
    type          = "windows"
    name          = module.naming.windows_virtual_machine.name
    resourcegroup = module.rg.groups.demo.name
    location      = module.rg.groups.demo.location

    interfaces = {
      int = { subnet = module.network.subnets.int.id }
      mgt = { subnet = module.network.subnets.mgt.id }
    }
  }
}
```