# vigilant-pancake

Demo for quickly starting a data platform on Azure.

## 0. Prerequisites
- terraform
- azure-cli
- vscode (really need to ask ?)
- azure subscription with money =D

## 1. Launch terraform
``` bash
cd terraform
terraform init --upgrade
terraform plan --input=true --out=plan.tfplan
terraform apply "plan.tfplan"
```

## 2. Upload data


## 3. Start pipeline

## 4. Cleanup

The command will destroy everyting inside the resource group.

``` bash
cd terraform
terraform destroy
``` 
