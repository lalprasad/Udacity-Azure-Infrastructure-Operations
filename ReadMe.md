# Deploying a web server in  Azure VM with Packer Image and  Terraform

## Introduction
In this project, we will deploy a web server  by leveraging the power or Microsoft Azure, Packer and Terraform.

Hashicorp's Packer is an open source tool for creating golden images for multiple platforms from a single source configuration.

Terraform is a powerful open-source infrastructure as code (IAAS) software tool created by HashiCorp. Users define and provision data center infrastructure using a declarative configuration language known as HashiCorp Configuration Language (HCL).


## Getting Started
Webserver will be deployed in an Azure VM Availability Set and the image is created using Packer. Entire infrastructure  is  provisioned via Terraform IAAS tool.


## Dependencies

Below are the pre-requisites needed for the project.
	� Azure Account with enough credit
	� Installation of latest version of Terraform, Packer and Azure CLI


## Instructions

	� Enforce an azure policy definition to deny creation of resources that do not have tags.
	� Use an Ubuntu 18.04-LTS SKU as the base image and create a Packer Image with the webserver.
	� Create the infrastructure using Terraform with the below steps
		?  Create a Resource Group
		?  Create a VNET and subnet in it
		?  Create a NSG, that explicitly allow access to other VMs in the subnet and deny access from the internet
		?  Create a Network Interface (NI)
		?  Create a public IP
		?  Create a LB that has a backend address pool and address pool association for the NI and LB
		?  Create a VM availability set
		?  Create VMs. Make sure you use the image you deployed using packer
		?  Create Managed Disks for the VMs
	� Deploy the infrastructure with Terraform

	How to build from Packer template?
	Use the command "packer build <json source name> to build from Packer template.

	How to run Terraform template?
	Below commands are used to build the infrastructre components via Terraform

	1. terraform init
	2. terraform plan -out example1.plan ( This creates the execution plan. -out parameter is used to persist the plan to a file)
	3. terraform apply example1.plan  (for applying the changes to reach DSC or set of pre-determined set of actions generated by a terraform plan execution plan)
		


Note: Terraform allow use vars.tf where the frequently used input variables for main.tf. This improves the reusability of the code.


## Output
Should be able to access the Public IP and able to access the web-server deployed in the VM
