## Slide 1 Atlantis Architecture

Atlantis is a tool that brings automation to Terraform or Terragrunt workflows inside Git.

It listens for pull requests, runs a plan automatically, and posts the results as a comment in the PR.
This gives reviewers immediate feedback on what changes will be made before anything is applied.

Once the changes are approved, an authorized reviewer can trigger apply directly from a PR comment, and Atlantis will execute it.

This setup ensures every infrastructure change is `peer-reviewed`, `tested`, and `auditable`.

## Slide 2 Example atlantis.yaml
Here’s a minimal `atlantis.yaml` configuration file for a `terraform`-based project.

In this example, we have a single project called `minimal` pointing to the `terraform-minimal` directory.
The workflow named `terraform` defines two stages — plan and apply.

This setup can be expanded with steps like terraform `fmt`, `validate`, or `tfsec` to enforce quality and security checks automatically.

## Slide 3 Atlantis Demo Flow
Let’s walk through the Atlantis workflow in practice:
 - Step 1 — A developer opens a pull request with Terraform changes.
 - Step 2 — Atlantis automatically detects the change and runs a plan, posting the output as a PR comment.
 - Step 3 — The reviewer reads the plan, checks for correctness, and if it’s good, approves the PR.
 - Step 4 — The reviewer comments atlantis apply in the PR, triggering the apply step.
 - Step 5 — Atlantis applies the changes and posts the final output as a PR comment.
 - 
This process keeps the entire change history in Git and ensures consistent, collaborative infrastructure management.