region = us-east-1
name = eks-cluster
profile = 340924313311_Administrator

# Configure the worker nodes on EKS
config:
	@aws eks --region $(region) update-kubeconfig --name $(name) --profile $(profile)