region?=eu-west-1

ifndef profile
$(error You must specify profile parameter)
endif

ifndef subnet_id
$(error You must specify subnet_id parameter)
endif

inspect:
	packer inspect template.json
	packer validate -var-file variables.json template.json

build: inspect
	packer build \
		-var-file variables.json \
		-var "region=$(region)" \
		-var "profile=$(profile)" \
		-var "subnet_id=$(subnet_id)" \
		template.json
