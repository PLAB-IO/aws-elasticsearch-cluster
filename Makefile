env?=testing
-include environments/$(env).mvars

ifndef accountId
$(error You must specify accountId parameter)
endif

ifndef roleName
$(error You must specify roleName parameter)
endif

ifndef bucket
$(error You must specify bucket parameter)
endif

ifdef profile
profile_selection=--profile $(profile)
endif

## GLOBAL SETTINGS
region?=eu-west-1
regionAzs?=3
stack_name?=aws-es-cluster
prefix?=stacks
roleName?=cloudformation-role
role?=arn:aws:iam::${accountId}:role/${roleName}
privateDomain?=es.lan

package:
	sam package \
		$(profile_selection) \
		--region $(region) \
		--s3-bucket $(bucket) \
		--s3-prefix $(prefix) \
		-t stacks/main.yml \
		--output-template-file main.template

deploy: package
	sam deploy \
		$(profile_selection) \
		--region $(region) \
		--template-file main.template \
		--capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_AUTO_EXPAND" \
		--role-arn $(role) \
		--stack-name $(stack_name) \
		--parameter-overrides \
	  		VpcId=$(vpcId) \
	  		PrivateSubnets=$(privateSubnets) \
	  		AvailabilityZones=$(availabilityZones) \
			AmiId=$(elasticAmiId) \
			KeyPair=$(keyPair) \
			BastionSecurityGroupId=$(bastionSecurityGroupId) \
			DataInstanceType=$(dataInstanceType) \
			ClusterName=$(clusterName) \
			PrivateHostedZoneId=$(privateHostedZoneId) \
			PrivateHostedZoneName=$(privateDomain) \
			BaseDomain=$(baseDomain) \
			EnableMasterHa=$(enableMasterHa) \
			EnableKibana=$(enableKibana)

clean:
	rm -rf .aws-sam main.template

delete:
	aws cloudformation delete-stack \
		--profile $(profile) \
		--region $(region) \
		--stack-name $(stack_name)

describe:
	aws --profile $(profile) \
		--region $(region) \
	  cloudformation describe-stacks \
		--stack-name $(stack_name) \
		--query 'Stacks[0].Outputs[*].[OutputKey, OutputValue]' --output text
