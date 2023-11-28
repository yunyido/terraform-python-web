variable "image_id" {
  description = "镜像ID"
  default     = "centos_7_8_x64_20G_alibase_20211130.vhd"
  type        = string
}

variable "security_groups" {
  description = "安全组"
  default     = [""]
  type        = list(string)
}

variable "spot_strategy" {
  description = "竞价实例策略"
  default     = "SpotAsPriceGo"
  type        = string
}

variable "system_disk_category" {
  default     = "cloud_efficiency"
  description = "系统盘类型"
  type        = string
}

variable "docker_install_url" {
  description = "docker安装脚本"
  default     = "http://yum.idcos.com/opensource/docker/docker-deploy.sh"
  type        = string
}