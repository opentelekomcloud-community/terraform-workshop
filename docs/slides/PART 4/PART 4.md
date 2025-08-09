## Slide 1  DRY Structure & Environment Separation:
Terragrunt is a lightweight wrapper around Terraform that helps us write cleaner, more maintainable code.

The main idea is to keep Terraform modules reusable and avoid repeating configuration.

We place reusable building blocks — like VPC or VM definitions — inside a modules/ directory.
Then, in the live/ directory, we keep environment-specific configurations, such as dev, stage, or prod.
Each environment imports the same module but passes in different variables, so the infrastructure is consistent but customized for each stage.

## Slide 2 Remote State Generation
One of Terragrunt’s biggest advantages is that it can generate backend and provider configuration automatically.
This means we don’t have to copy backend blocks into every environment - it’s centrally defined in `terragrunt.hcl` at the root.

For OTC, we can use `OBS (Object Storage Service) `as a remote state backend because it’s S3-compatible.
Centralizing this setup ensures every environment uses the same backend settings, which `reduces configuration drift` and `simplifies onboarding`.

## Slide 3 Example Terragrunt Repo Layout
Here’s a typical Terragrunt project structure:

We have a `modules/` directory for reusable code,

a `live/` directory for actual environments,

and a root `terragrunt.hcl` file for shared settings.

Inside `live/eu-de/dev`, we might have a Terragrunt configuration that calls our vm-nginx module with dev-specific parameters.

In `live/eu-de/prod`, we call the same module but with larger flavors, more instances, or different networking rules.

This approach makes scaling and maintaining multiple environments much easier.