ssh-keygen -t rsa -b 4096 -f /home/ubuntu/.ssh/web
terraform init
terraform plan
terraform apply --auto-approve
