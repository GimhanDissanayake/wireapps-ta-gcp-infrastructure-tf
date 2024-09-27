TF_WORKSPACE=nonprod-use1

plan:
	terraform workspace select ${TF_WORKSPACE}
	terraform fmt -recursive .
	cp tfvars/${TF_WORKSPACE}.auto.tfvars .
	terraform init
	terraform validate
	terraform plan
	rm ${TF_WORKSPACE}.auto.tfvars

apply:
	terraform workspace select ${TF_WORKSPACE}
	cp tfvars/${TF_WORKSPACE}.auto.tfvars .
	terraform init
	terraform validate
	terraform apply
	rm ${TF_WORKSPACE}.auto.tfvars

destroy:
	terraform workspace select ${TF_WORKSPACE}
	cp tfvars/${TF_WORKSPACE}.auto.tfvars .
	terraform destroy
	rm ${TF_WORKSPACE}.auto.tfvars