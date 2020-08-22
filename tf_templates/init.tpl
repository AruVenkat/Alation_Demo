[webservers]
${ip_address}

[webservers:vars]
ansible_ssh_user=ubuntu
ansible_ssh_common_args='-F ssh_config'
ansible_python_interpreter=/usr/bin/python3
