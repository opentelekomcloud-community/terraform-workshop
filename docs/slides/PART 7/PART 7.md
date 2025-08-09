## Slide 1 Language-based IaC

Pulumi takes a different approach from Terraform, instead of using a domain-specific language like HCL, it allows you to write your infrastructure as code in general-purpose programming languages.

You can use `Python`, `TypeScript/JavaScript`, `Go`, or `C#`.

This opens the door to leveraging familiar language features like `loops`, `conditionals`, `functions`, and even `unit testing` in your infrastructure definitions.
It can be easier for development teams to adopt if they want infrastructure code to live alongside application code.

## Slide 2 Mapping to OTC/OpenStack Provider
Pulumi interacts with cloud platforms using `SDKs` and `APIs`, just like `Terraform` uses providers.
For `OpenTelekomCloud`, Pulumi we can even use the `OpenStack` provider, because OTC is `OpenStack-based`.

The concepts are similar — you’ll define resources like instances, networks, and volumes — but you’ll use the syntax of the programming language you choose.
If you know how to use the OTC provider in Terraform, mapping that knowledge to Pulumi’s OpenStack provider is straightforward.

## Slide 3 Pulumi Example (Python)
Here’s a simple Pulumi example in Python for creating a VM.

We import pulumi and pulumi_openstack, then define a new Instance resource called `workshop-vm`.

We specify the image, flavor, and network just like we would in `Terraform`, but here it’s Python code.

Finally, we export the VM’s public IP as an output, so it’s displayed after the deployment.

This shows how similar the concepts are between Pulumi and Terraform, even though the syntax and execution model differ.
