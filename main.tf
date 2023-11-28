provider "alicloud" {
  access_key = "LTAI5tGZXBYS8ctpXPwnpKuR"
  secret_key = "PI225V2Zz571bjeJ4sYLLefGOSoZzH"
  region     = "cn-beijing"
}

data "alicloud_instance_types" "this" {
  cpu_core_count       = 2
  memory_size          = 4
  instance_charge_type = "PostPaid"
  spot_strategy        = var.spot_strategy
  image_id             = var.image_id
  sorted_by            = "Price"
  system_disk_category = var.system_disk_category
}

locals {
  instance_types    = data.alicloud_instance_types.this.instance_types[0]
  instance_type     = local.instance_types.id
  availability_zone = local.instance_types.availability_zones[0]
}

data "alicloud_vpcs" "vpcs" {
  name_regex = "^ydd-vpc"
}

locals {
  vpc_id = data.alicloud_vpcs.vpcs.vpcs[0].id
}

data "alicloud_vswitches" "vswitches" {
  name_regex = "^ydd-vswitch"
  vpc_id     = local.vpc_id
  zone_id    = local.availability_zone
}

data "alicloud_security_groups" "sec_groups_ds" {
  name_regex = "^ydd-security-group"
  vpc_id     = local.vpc_id
}

locals {
  security_groups = data.alicloud_security_groups.sec_groups_ds.groups[*].id
  vswitch_id      = data.alicloud_vswitches.vswitches.vswitches[0].id
}

resource "alicloud_instance" "this" {
  image_id                   = var.image_id
  instance_type              = local.instance_type
  spot_strategy              = var.spot_strategy
  security_groups            = local.security_groups
  key_name                   = "ydd-keypair"
  internet_max_bandwidth_out = 10
  vswitch_id                 = local.vswitch_id
  system_disk_category       = var.system_disk_category
  system_disk_size           = 40
  password                   = "Abc123456"
}

resource "null_resource" "ssh" {
  connection {
    type     = "ssh"
    user     = "root"  # Replace with the appropriate username for your EC2 instance
    password = "Abc123456"  # Replace with the path to your private key
    host     = alicloud_instance.this.public_ip
  }

  provisioner "file" {
    source      = "docker-deploy.sh"
    destination = "/root/docker-deploy.sh"
  }

  #  安装docker
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y", # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip", # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}
