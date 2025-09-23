# PowerShell script to automate Lambda packaging, Terraform apply, and Git push
# Usage: Run this script from the root of the resume-website-s3 solution

# Step 1: Package Lambda functions using Ansible
Write-Host "[1/3] Packaging Lambda functions with Ansible..."
ansible-playbook ansible/repackage-lambdas.yml
if ($LASTEXITCODE -ne 0) {
    Write-Error "Ansible playbook failed. Exiting."
    exit 1
}

# Step 2: Run Terraform plan and apply
Write-Host "[2/3] Running Terraform plan and apply..."
cd terraform
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform init failed. Exiting."
    exit 1
}
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform plan failed. Exiting."
    exit 1
}
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform apply failed. Exiting."
    exit 1
}
cd ..

# Step 3: Commit and push changes to Git
Write-Host "[3/3] Committing and pushing changes to Git..."
git add .
git commit -m "Automated: package Lambda, apply Terraform, update infra"
git push
if ($LASTEXITCODE -ne 0) {
    Write-Error "Git push failed. Please check your remote settings."
    exit 1
}

Write-Host "All steps completed successfully!"