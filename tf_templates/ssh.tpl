Host bastion
  Hostname ${bastion_host}
  User ubuntu
  IdentityFile ${private_key}

Host ${host_range}
  ProxyJump bastion
  User ubuntu
  IdentityFile ${private_key}