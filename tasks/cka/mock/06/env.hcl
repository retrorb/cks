locals {
  questions_list="https://github.com/retrorb/cks/blob/master/tasks/cka/mock/06/README.MD"
  solutions_scripts="https://github.com/retrorb/cks/tree/master/tasks/cka/mock/06/worker/files/solutions"
  solutions_video=""
  region = "eu-north-1"
  vpc_default_cidr =  "10.2.0.0/16"
  az_ids = {
    "10.2.0.0/19"  = "eun1-az3"
    "10.2.32.0/19" = "eun1-az2"
  }
  aws    = "default"
  prefix = "cka-mock"
  tags = {
    "env_name"        = "cka-mock"
    "env_type"        = "dev"
    "manage"          = "terraform"
    "cost_allocation" = "dev"
    "owner"           = "viktoruj@gmail.com"
  }
  k8_version           = "1.30.0"
  node_type            = "spot"
  runtime              = "containerd"
  instance_type        = "t3.medium"
  instance_type_worker = "t3.small"
  ubuntu_version       = "20.04"
  key_name             = ""
  ssh_password_enable  = "true"
  access_cidrs         = ["0.0.0.0/0"]
  ami_id               = ""
  root_volume = {
    type = "gp3"
    size = "12"
  }
}
