all:
	terraform init -upgrade
	terraform fmt -recursive
	terraform validate
	TF_LOG=debug terraform plan
