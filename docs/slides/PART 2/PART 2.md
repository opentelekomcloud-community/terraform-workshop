## Slide 1 HCL Syntax & Providers:
Terraform uses HashiCorp Configuration Language, or HCL, which is designed to be both human-readable and machine-parsable.
In HCL, we describe the desired state of our infrastructure, and Terraform figures out how to reach that state.
The way Terraform interacts with different platforms is through providers. Each provider knows how to talk to a specific API and manage resources there.
In our case, we’ll use the OpenTelekomCloud provider, which is based on OpenStack, so a lot of OpenStack concepts will be familiar if you’ve worked with it before.

## Slide 2 OTC Provider Configuration:
Here’s a short example of configuring the OTC provider in Terraform.
We specify the region - for OTC we’ll use eu-de in this workshop.
The auth_url points to OTC’s IAM endpoint, the domain_name is your OTC domain, and we provide our credentials either directly as variables or via environment variables for security.
This block tells Terraform: “Use the OpenTelekomCloud API in this region with these credentials.”

## Slide 3 Minimal VM Deployment (OTC):
This is a simple VM resource in OTC using the opentelekomcloud_compute_instance_v2 resource.
We give it a name, choose an image - here Ubuntu 22.04 - and a flavor like s2.small.1.
The key_pair ensures we can SSH into the VM after it’s created.
Finally, the network block specifies which subnet the VM should connect to, using the subnet’s network ID.
This is the smallest possible building block for OTC infrastructure in Terraform.

## Slide 4 Variables & Outputs:
Variables let us make our configurations reusable and avoid hardcoding values.
For example, we can have a username variable to pass in at runtime or from a .tfvars file.
Outputs let us easily retrieve important values from the deployment - like the VM’s public IP - without digging through the state file.
Here, output "vm_ip" will display the VM’s IP address right after a successful terraform apply.