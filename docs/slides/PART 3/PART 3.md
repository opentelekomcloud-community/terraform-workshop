## Slide 1 Loops: count & for_each:
Terraform gives us two main ways to repeat resource creation: `count` and `for_each`.

`count` is great for creating multiple identical copies of a resource, such as spinning up three identical VMs.

`for_each` is more flexible - it lets you create resources from a list or a map, and you can use the keys or values in naming and configuration.

In `OTC`, for example, we could create `multiple subnets in a VPC` by iterating over a map of CIDR blocks.
Choosing between count and for_each depends on whether you need positional indexing or key-based iteration.

## Slide 2 Conditionals in Terraform:
Conditionals let us control resource attributes or even whether a resource is created at all.
The syntax is: condition ? true_value : false_value.
This is useful for things like controlling high availability.
For example, if high_availability is set to true, we can deploy one VM per availability zone; otherwise, just deploy one VM.
This makes configurations more adaptable without duplicating code.

## Slide 3 Local Values:
Locals in Terraform are variables whose values are computed from other variables or expressions.
They help reduce repetition and make code cleaner.

For example, we might define a `local.common_tags` map that contains tags like Environment and Project.

Then, we merge these locals into the tags block of each resource.
This way, if we change the environment name once in locals, it updates everywhere automatically.

## Slide 4 State Management & Remote Backends:
Terraform stores the infrastructure state in a file, usually called `terraform.tfstate`.

When working alone, this can be local. But in a team, you need a remote backend so everyone shares the same state.
On `OTC`, we can use `OBS` - Object Storage: as an `S3`-compatible backend for Terraform state.
Remote backends allow for state locking and history tracking, which prevents conflicts and keeps deployments consistent.

## Slide 5 Importing Existing Resources:
Importing lets you bring existing infrastructure under Terraform’s control without recreating it.

The syntax is: **terraform import <resource_type>.<name> <cloud_id>**.

For example, if you have an OTC VM with ID 1234-5678, you could run:
```bash
terraform import opentelekomcloud_compute_instance_v2.vm 1234-5678
```
This is especially useful when starting with existing resources or recovering from manual changes.