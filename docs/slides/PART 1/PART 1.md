## Slide 1 Title:
Welcome to Part 1 of our workshop: Intro & IaC Landscape.
In this section, we’ll compare Terraform, Pulumi, and then look at how GitOps works with Atlantis to automate infrastructure changes.
This will give you a broad understanding of the tools and workflows before we get hands-on.

## Slide 2 IaC Tools Comparison:
Let’s start with the three main tools in our scope:
Terraform is a declarative Infrastructure-as-Code tool using HashiCorp Configuration Language (HCL). It supports hundreds of providers, including OpenTelekomCloud, Openstack, AWS, Azure, and more.
Pulumi takes a similar IaC approach but lets you use general-purpose programming languages like Python, TypeScript, Go, or C#. This makes it appealing if your team prefers one language for both application and infrastructure.
Knowing the strengths of each tool helps you choose the right one for your project or combine them effectively.

## Slide 3 GitOps and Atlantis Workflow:
GitOps is about managing infrastructure the same way we manage application code — through pull requests and version control.
In a GitOps workflow, all changes are proposed via pull requests, reviewed by peers, and merged only after automated validation.
Atlantis is a tool that integrates directly with Git repositories to automate Terraform commands.
When you open a pull request, Atlantis automatically runs plan and comments the output in the PR. After review, an authorized user can approve and trigger apply directly from the PR comment.
This ensures every change is peer-reviewed, tested, and auditable, bringing infrastructure workflows closer to software development best practices.
