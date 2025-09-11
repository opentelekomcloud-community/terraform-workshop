## Slide 1 Title
## Slide 2 Prerequisites
## Slide 3 Infrastructure As Code:
The process of managing infrastructure with tools that use configuration files (typically declarative) to consistently provision hardware into a defined state with each execution.

Idempotence is a fundamental principle of Infrastructure as Code (IaC).
 * Each deployment execution consistently enforces the same desired state.
   * For example, if a server is already configured with the correct user accounts and packages, reapplying the configuration does not duplicate users or reinstall packages unnecessarily.

## Slide 4 Benefits of IaC:
Reproducible infrastructure
 * → Infrastructure can be reliably recreated in the same way every time.

Easy redeployable
 * → Environments can be quickly redeployed with minimal effort.

Solution to infrastructure drift
 * → Ensures consistency by preventing or correcting infrastructure drift.

Can be stored in VCS
 * → Configurations can be version-controlled in source repositories.

Easily automated
 * → Infrastructure management can be fully automated.

## Slide 5 Other tools:
Configuration Management Tools: manage resources after provisioning
 * Provisioning: hardware / OS (e.g., Terraform, CloudFormation)
 * Configuration: software setup (e.g., Ansible, Puppet, Chef)

IaC + Configuration Management
 * work best when combined

Example: Use Terraform to create servers, then Ansible to install and configure applications

## Slide 6 Terraform:
Terraform is a tool by Hashicorp, is an Infrastructure as Code
 * Two main options:
   * Terraform CLI – to run locally in  your own CI/CD
   * Terraform Cloud for Enterprise
     * Cloud – Remote State Management with CI/CD integrations.
     * Enterprise – Self-hosted distribution of Terraform Cloud

 * Terraform has many providers for provisioning many types of resources
 * Registry of community build providers and modules
 * Now you can use not only Terraform but OpenTofu (complete community version)

## Slide 7 Basics - Providers:
Terraform uses HashiCorp Configuration Language, or HCL, which is designed to be both human-readable and machine-parsable.

In HCL, we describe the desired state of our infrastructure, and Terraform figures out how to reach that state.

The way Terraform interacts with different platforms is through providers. Each provider knows how to talk to a specific API and manage resources there.

In our case, we’ll use the `OpenTelekomCloud` provider, which is based on `OpenStack`, so a lot of `OpenStack` concepts will be familiar if you’ve worked with it before.

Here’s a short example of configuring the OTC provider in Terraform.

We specify the region - for OTC we’ll use `eu-de` in this workshop.

The `auth_url` points to OTC’s IAM endpoint, the `domain_name` is your OTC domain, and we provide our credentials either directly as variables or via environment variables for security.

This block tells Terraform: “Use the OpenTelekomCloud API in this region with these credentials.”

## Slide 8 Basics - Variables and Outputs:
Variables let us make our configurations reusable and avoid hardcoding values.

For example, we can have a username variable to pass in at runtime or from a `.tfvars` file.

Outputs let us easily retrieve important values from the deployment, like the VM’s public IP without digging through the state file.

Here, output "vm_ip" will display the VM’s IP address right after a successful terraform apply.

## Slide 9 Basics - Minimal VM Configuration:
This is a simple VM resource in OTC using the `opentelekomcloud_compute_instance_v2` resource.

We give it a name, choose an image here `Ubuntu 22.04` and a flavor like `s2.small.1`.

The `key_pair` ensures we can SSH into the VM after it’s created.

Finally, the network block specifies which subnet the VM should connect to, using the subnet’s network ID.

This is the smallest possible building block for OTC infrastructure in Terraform.

## Mininal showcase

## Slide 10 Advanced - Loops:
Terraform gives us two main ways to repeat resource creation: by using metaarguments `count` and `for_each`.

`count` is great for creating multiple identical copies of a resource, such as spinning up three identical VMs.
```hcl
variable "web_count"   { type = number }
variable "image_id"    { type = string }
variable "flavor_id"   { type = string }
variable "keypair"     { type = string }
variable "network_id"  { type = string }

resource "opentelekomcloud_compute_instance_v2" "web" {
  count     = var.web_count
  name      = "web-${count.index}"
  image_id  = var.image_id
  flavor_id = var.flavor_id
  key_pair  = var.keypair

  network {
    uuid = var.network_id
  }

  security_groups = ["default"]
}

output "web_instance_names" {
  value = [for i in opentelekomcloud_compute_instance_v2.web : i.name]
}
```

`for_each` is more flexible - it lets you create resources from a list or a map, and you can use the keys or values in naming and configuration.
```hcl
variable "servers" {
  description = "Map of server name => parameters"
  type = map(object({
    image_id   = string
    flavor_id  = string
    network_id = string
  }))
}

resource "opentelekomcloud_compute_instance_v2" "srv" {
  for_each  = var.servers

  # key becomes the resource name
  name      = each.key
  image_id  = each.value.image_id
  flavor_id = each.value.flavor_id
  key_pair  = var.keypair

  network {
    uuid = each.value.network_id
  }
}
```

Choosing between `count` and `for_each` depends on whether you need `positional indexing` or `key-based` iteration.

## Slide 11 Advanced - Conditionals:

Conditionals let us control resource attributes or even whether a resource is created at all.

The syntax is: `condition ? true_value : false_value`.

This is useful for things like controlling high availability.

For example, if `high_availability` is set to true, we can deploy one VM per availability zone, otherwise, just deploy one VM.

This makes configurations more adaptable without duplicating code.
```hcl
variable "high_availability" {
description = "Enable HA mode with one VM per AZ"
type        = bool
default     = false
}

# Conditional VM deployment
resource "opentelekomcloud_compute_instance_v2" "vm" {
  count = var.high_availability ? length(data.opentelekomcloud_availability_zones_v3.azs.names) : 1

  name      = var.high_availability ? "ha-vm-${count.index}" : "single-vm"
  image_id  = var.image_id
  flavor_id = var.flavor_id
  key_pair  = var.keypair

  network {
    uuid = var.network_id
  }

  availability_zone = var.high_availability ? data.opentelekomcloud_availability_zones_v3.azs.names[count.index] : null
}
```

If `high_availability` = `false`, Terraform deploys 1 VM.
•  If `high_availability` = `true`, Terraform deploys 1 VM per AZ.

## Slide 12 Advanced - Local Values:
Locals in Terraform are variables whose values are computed from other variables or expressions.
They help reduce repetition and make code cleaner.

For example, we might define a local.common_tags map that contains tags like `Environment` and `Project`.

Then, we merge these locals into the tags block of each resource.
This way, if we change the environment name once in locals, it updates everywhere automatically.
```hcl
# Define common tags once
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ECS instance with merged tags
resource "opentelekomcloud_compute_instance_v2" "app" {
  name      = "app-server"
  image_id  = var.image_id
  flavor_id = var.flavor_id
  key_pair  = var.keypair

  network {
    uuid = var.network_id
  }

  tags = merge(
    local.common_tags,
    { Role = "Application" }
  )
}
```

## Slide 13 Advanced - State Management and Remote Backends:
Terraform stores the infrastructure state in a file, usually called `terraform.tfstate`.

When working alone, this can be local. But in a team, you need a remote backend so everyone shares the same state.
On OTC, we can use `OBS - Object Storage`: as an `S3-compatible` backend for Terraform state.
Remote backends allow for state locking and history tracking, which prevents conflicts and keeps deployments consistent.
Can store also in:
 * Consul (KV store with locking)
 * etcd
 * HTTP (custom remote state API)
 * Local (default, but only safe for single-user work)

## Slide 14 Advanced - Import Existing Resources:
Importing lets you bring existing infrastructure under Terraform’s control without recreating it.

The syntax is: **terraform import <resource_type>.<name> <cloud_id>**.

For example, if you have an OTC VM with ID 1234-5678, you could run:
```bash
terraform import opentelekomcloud_compute_instance_v2.vm 1234-5678
```
This is especially useful when starting with existing resources or recovering from manual changes.

## Slide 15 Multitenancy - Folder-based separation:
In this section, we’ll explore how to manage multiple tenants or environments in Terraform, especially when using remote state for storing `.tfstate` files.

We’ll compare two main approaches: `folder-based` separation and `workspace-based` separation and examine how each handles backend configuration, state isolation, and operational complexity.

By the end, you’ll know which approach best fits your infrastructure and security requirements, and how to combine them with shared modules for an efficient multitenancy setup.

In a `folder-based` approach, each tenant or environment has its own directory.
Each directory contains its own backend.tf pointing to a unique remote state location, for example, a different key or even a different OBS bucket.
This gives complete isolation of state files and allows different credentials or backends per tenant.

Shared Terraform modules can live in a central `modules/` folder, allowing you to reuse infrastructure definitions without copy-pasting code.
Each folder requires its own `terraform init`, `plan`, and `apply`, which ensures separation but can be more work to manage.


`+/-`

With remote state, folder-based separation allows:
* Different backends or credentials for each tenant.
* State stored in completely separate OBS buckets or keys, improving security and reducing blast radius.
  The cost is more repetition in backend configuration, and you must run terraform init separately for each folder.

Folder-based separation gives us fully isolated backends and state files per tenant, which makes it easier to apply different provider credentials or backend settings.

It also provides clear separation for access control and compliance.

On the downside, it creates more file duplication, you often have to repeat backend and provider configuration and without modules, it’s harder to keep everything consistent.

## Slide 16 Multitenancy - Workspace-based separation:
We use commands like terraform `workspace new tenant-a` and `terraform workspace select tenant-b` to switch between them.

The backend configuration uses the workspace name to store separate state files, often via `${terraform.workspace}` in the key path.
This is highly DRY, but it also means all workspaces `share the same backend configuration and provider settings`.

In a workspace-based approach, we use a single codebase and a single backend configuration.
The backend key parameter usually includes `${terraform.workspace}` so each workspace stores its state in a different file under the same backend.
All workspaces `must share the same backend type and authentication`. This is simpler to manage, but `less flexible for per-tenant isolation`.

With remote state, workspace-based separation:
* Automatically isolates state files by workspace key naming.
* Uses one backend configuration for all tenants: easy to set up and DRY.

The limitation is that you `cannot vary backend settings or credentials per tenant`. All share the same OBS bucket and auth.
Workspace-based separation minimizes duplication, there’s only one set of Terraform files to maintain.

It’s easy to switch tenants with a single command, and all tenants automatically share module code.

The trade-off is that all workspaces share the same backend configuration, which may not be acceptable for strict isolation.

There’s also a `risk of accidentally running commands in the wrong workspace` if you forget to switch.

## Slide 17 Multitenancy - Summary:
When using remote state:
* Use folders if you need different credentials, buckets, or backend types per tenant.
* Use workspaces if you want simplicity, all tenants are similar, and one backend fits all.
  You can also combine: shared modules for consistency, plus the separation method that fits your state storage and security needs.

`Folder-based separation` works best when tenants have different configurations, different credentials, or strict isolation requirements.

`Workspace-based separation` works best when all tenants are very similar, and you want maximum code reuse with minimal duplication.

## Multitenancy showcase

## Slide 18 Atlantis - Architecture:
Atlantis is a tool that brings automation to Terraform workflows inside Git.

It listens for pull requests, runs a plan automatically, and posts the results as a comment in the PR.
This gives reviewers immediate feedback on what changes will be made before anything is applied.

Once the changes are approved, an authorized reviewer can trigger apply directly from a PR comment, and Atlantis will execute it.

This setup ensures every infrastructure change is `peer-reviewed`, `tested`, and `auditable`.

## Slide 19 Atlantis - Configuration:
Here’s a minimal `atlantis.yaml` configuration file for a `terraform`-based project.

In this example, we have a single project called `minimal` pointing to the `terraform-minimal` directory.
The workflow named `terraform` defines two stages — plan and apply.

This setup can be expanded with steps like terraform `fmt`, `validate`, or `tfsec` to enforce quality and security checks automatically.

## Slide 20 Atlantis - Flow:
Let’s walk through the Atlantis workflow in practice:
* Step 1: A developer opens a pull request with Terraform changes. 
* Step 2: Atlantis automatically detects the change and runs a plan, posting the output as a PR comment. 
* Step 3: The reviewer reads the plan, checks for correctness, and if it’s good, approves the PR. 
* Step 4: The reviewer comments atlantis apply in the PR, triggering the apply step. 
* Step 5: Atlantis applies the changes and posts the final output as a PR comment.

This process keeps the entire change history in Git and ensures consistent, collaborative infrastructure management.

## Slide 21 Pulumi - Language-based IaC:
Pulumi takes a different approach from Terraform, instead of using a domain-specific language like HCL, it allows you to write your infrastructure as code in general-purpose programming languages.

You can use `Python`, `TypeScript/JavaScript`, `Go`, or `C#`.

This opens the door to leveraging familiar language features like `loops`, `conditionals`, `functions`, and even `unit testing` in your infrastructure definitions.
It can be easier for development teams to adopt if they want infrastructure code to live alongside application code.

## Slide 22 Pulumi - Mapping:
Pulumi interacts with cloud platforms using `SDKs` and `APIs`, just like `Terraform` uses providers.
For `OpenTelekomCloud`, Pulumi we can even use the `OpenStack` provider, because OTC is `OpenStack-based`.

The concepts are similar — you’ll define resources like instances, networks, and volumes — but you’ll use the syntax of the programming language you choose.
If you know how to use the OTC provider in Terraform, mapping that knowledge to Pulumi’s OpenStack provider is straightforward.

## Slide 23 Pulumi - Quick Start:
Here is few commands for quick start
To Bootstrap your project with templates
`Pulumi new`

To manage and view state of current stack
`Pulumi stack`

Set the default destination org for all stack operations
`pulumi org set-default NAME`

View backend, current stack, pending operations, and versions
`pulumi about`

## Slide 24 Pulumi - Example and Showcase:
Here’s a simple Pulumi example in Python for creating a VM.

We `import pulumi and pulumi_openstack` then define a new Instance resources called `workshop-`.

We specify the `image`, `flavor`, and `network` just like we would in Terraform, but here it’s `Python` code.

Pulumi OpenStack (OTC) – Deploying Multiple VMs

**Goal**: Provision several identical VMs in a custom network with router + floating IPs

Key Elements in the Code
 * Configurable instance count (pulumi config set example:instance_count 3)
 * Network setup: Private subnet, router with external gateway 
 * Security group: ICMP (ping) enabled 
 * Loop over count:
   * Create port in subnet 
   * Create VM attached to port 
   * Allocate Floating IP and associate to port
 * Exports: `internal IPs`, `floating IPs`, `network`, `subnet`, `router` IDs

---

Example Workflow
1. `pulumi up` → creates 2 VMs by default
2. Adjust with config:

`pulumi config set example:instance_count 3`

3. Run ping <floating_ip> to test connectivity

---
Benefits
 * Declarative infrastructure as code in Python
 * Scales easily with parameterized instance_count
 * Reusable pattern for multi-VM labs, demos, or clusters
Finally, we export the VM’s public IP as an output, so it’s displayed after the deployment.

This shows how similar the concepts are between Pulumi and Terraform, even though the syntax and execution model differ.

## Slide 25:

Over the past sessions, we’ve walked through the core concepts of Infrastructure as Code,
explored Terraform’s building blocks, practiced using the OpenTelekomCloud provider,
and looked at advanced patterns like automation with Ansible, multitenancy, and GitOps workflows.

You’ve seen how to start from a minimal deployment, grow it into reusable modules, and manage multiple tenants or environments with safe, remote-stored state.

The goal isn’t just to learn commands — it’s to design infrastructure that is consistent, secure, and easy to evolve.

Whether you apply these patterns with Terraform, integrate them into CI/CD pipelines, or extend them with other IaC tools, the principles remain the same: version your infrastructure, review every change, and automate wherever you can.
