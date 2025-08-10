## Slide 1  Multitenancy in Terraform:
In this section, we’ll explore how to manage multiple tenants or environments in Terraform, especially when using remote state for storing .tfstate files.

We’ll compare two main approaches: folder-based separation and workspace-based separation and examine how each handles backend configuration, state isolation, and operational complexity.

By the end, you’ll know which approach best fits your infrastructure and security requirements, and how to combine them with shared modules for an efficient multitenancy setup.

## Slide 2 Folder-based Separation
In a folder-based approach, each tenant or environment has its own directory.
Each directory contains its own `backend.tf` pointing to a unique remote state location, for example, a different key or even a different OBS bucket.
This gives complete isolation of state files and allows different credentials or backends per tenant.

Shared Terraform modules can live in a central `modules/` folder, allowing you to reuse infrastructure definitions without copy-pasting code.
Each folder requires its own terraform init, plan, and apply, which ensures separation but can be more work to manage.

## Slide 3 Workspace-based Separation
We use commands like terraform workspace new tenant-a and terraform workspace select tenant-b to switch between them.
The backend configuration uses the workspace name to store separate state files, often via `${terraform.workspace}` in the key path.
This is highly DRY, but it also means all workspaces share the same backend configuration and provider settings.

In a workspace-based approach, we use a single codebase and a single backend configuration.
The backend key parameter usually includes `${terraform.workspace}` so each workspace stores its state in a different file under the same backend.
All workspaces must share the same backend type and authentication. This is simpler to manage, but less flexible for per-tenant isolation.

## Slide 4 Pros & Cons: Folder-based
With remote state, folder-based separation allows:
 * Different backends or credentials for each tenant.
 * State stored in completely separate OBS buckets or keys, improving security and reducing blast radius.
The cost is more repetition in backend configuration, and you must run terraform init separately for each folder.

Folder-based separation gives us fully isolated backends and state files per tenant, which makes it easier to apply different provider credentials or backend settings.

It also provides clear separation for access control and compliance.

On the downside, it creates more file duplication, you often have to repeat backend and provider configuration and without modules, it’s harder to keep everything consistent.

## Slide 5 Pros & Cons: Workspace-based
With remote state, workspace-based separation:
 * Automatically isolates state files by workspace key naming.
 * Uses one backend configuration for all tenants: easy to set up and DRY.

The limitation is that you cannot vary backend settings or credentials per tenant. All share the same OBS bucket and auth.
Workspace-based separation minimizes duplication, there’s only one set of Terraform files to maintain.

It’s easy to switch tenants with a single command, and all tenants automatically share module code.

The trade-off is that all workspaces share the same backend configuration, which may not be acceptable for strict isolation.

There’s also a risk of accidentally running commands in the wrong workspace if you forget to switch.

## Slide 6 Choosing an Approach
When using remote state:
 * Use folders if you need different credentials, buckets, or backend types per tenant.
 * Use workspaces if you want simplicity, all tenants are similar, and one backend fits all.
You can also combine: shared modules for consistency, plus the separation method that fits your state storage and security needs.

Folder-based separation works best when tenants have different configurations, different credentials, or strict isolation requirements.

Workspace-based separation works best when all tenants are very similar, and you want maximum code reuse with minimal duplication.
