# Terraform
### Mac
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

### Linux
curl -fsSL https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip -o terraform.zip
unzip terraform.zip && sudo mv terraform /usr/local/bin/

### Windows
choco install terraform

# Pulumi
### Mac
brew install pulumi/tap/pulumi

### Linux
curl -fsSL https://get.pulumi.com | sh

### Windows
choco install pulumi