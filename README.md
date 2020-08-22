# Alation_Demo

# Introduction

This doc will take you to setting up two webservers, classic loadbalancer and bastion host using Terraform and Ansible. 

# Pre-requisites

here I have used Ubuntu linux flavour for webs and bastion server.

Lets assume already we have a server with Terraform and Ansible. It should configured with aws access and secret keys.

# Setting up infrastructure

This environment will be created on **_us-east-2_** region. the region has beed mentioned at **_variables.tf._**

The instance.tf file is a main file which is responsible to creating all the resources(webservers and bastion server), ansible dynamic inventory, dynamic ssh configuration file and triggering ansible playbook once all the resources has been created.

before triggering instance.tf file we need a public and private key to craete a keypair in aws. it's available in the start.sh file.

# Deploy Sample html App

there is a playbook(nginx_install.yml) in ansible folder which is used to install nginx server, staging index.html and starting nginx service.

I have kept 2 templating file to handle dynamic configurations.

# Steps to execute

1. Enter into the template directory
***$ cd Alation_Demo/tf_templates/***
2. enable execute permision for start.sh
***$ chmod +s start.sh***
2. run the script 
***$ ./start.sh***

***Pros***
1. Dynamic inventory
2. Dynamic ssh configuration file which will help to ansible navigate the private subnet instance using bastion host.


***Future improvements***
1. we can improve lot in ansible playbook when we have real time example.
2. formation of terraform is not good. for time being I have kept like this. we can split into multiple file or we can use modules if necessary 

***Output***
Following details will be shown in the output,

1. bastion host's public ip 
2. webserver's private ips
3. classic load balancer URL


***Thank You ! For Reading.***

