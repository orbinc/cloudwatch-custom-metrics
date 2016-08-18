Host fixme.bastion.example.com
  User ec2-user
  ForwardAgent yes
  IdentityFile ~/.ssh/fixme.id_rsa

Host 10.*
  User ec2-user
  StrictHostKeyChecking no
  ProxyCommand ssh -F ssh.cfg -W %h:%p fixme.bastion.example.com
