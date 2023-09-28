variable "region_aws" {
  description = "Region AWS"
  type        = string
  default     = "eu-west-3"
}

variable "access_key_aws" {
  description = "access_key_aws"
  type        = string
  //default     = ""
  default = "AKIAYBFAQKZOPN6UTREX"
}

variable "secret_key_aws" {
  description = "secret_key_aws"
  type        = string
  default     = "WQaicdDPoPINyKeuK+uh62WusHXkVj1hyHHfRfSN"
}

variable "vpc_rec_name" {
  description = "vpc_rec_name"
  type        = string
  default     = "recette"
}

variable "vpc_rec_cidr" {
  description = "vpc_rec_cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "gateway_name" {
  description = "gateway_name"
  type        = string
  default     = "gateway_recette"
}

//Nombre subnet privee et public

variable "subnet_count" {
  type        = map(number)
  description = "Nombre subnet privee et public"
  default = {
    public  = 1,
    private = 2
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "group_public_subnets_name" {
  description = "Nom groupe publique"
  type        = string
  default     = "omega_public_subnet_"
}

variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

variable "group_private_subnets_name" {
  description = "Nom groupe private"
  type        = string
  default     = "omega_private_subnet_"
}

variable "sg_omega_name_frontend" {
  description = "Nom du groupe de sécurité Omega Frontend"
  type        = string
  default     = "omega_frontend_sg"
}

variable "allowed_cidr_blocks_http" {
  description = "Liste des plages CIDR autorisées pour le trafic HTTP"
  type        = list(string)
  default     = [
    "88.174.68.140/32",
    "88.170.226.46/32",
    "146.70.40.18/32",
    "88.171.254.18/32",
    "88.173.182.55/32",
    "37.165.144.18/32",
    "37.167.215.179/32",
    "77.136.66.187/32",
    "88.168.83.128/32",
    "88.160.67.59/32"
  ]
}

variable "allowed_cidr_blocks_ssh" {
  description = "Liste des plages CIDR autorisées pour le trafic SSH"
  type        = list(string)
  default     = [
    "88.174.68.140/32",
    "88.170.226.46/32",
    "146.70.40.18/32",
    "88.171.254.18/32",
    "88.173.182.55/32",
    "37.165.144.18/32",
    "37.167.215.179/32",
    "77.136.66.187/32",
    "88.168.83.128/32",
    "88.160.67.59/32"
  ]
}



variable "sg_omega_db_name" {
  description = "Nom securité groupe omega db"
  type        = string
  default     = "sg_db_omega"
}

variable "omega_db_subnet_gr_name" {
  description = "Nom nom groupe subnet"
  type        = string
  default     = "omega_db_subnet_group"
}


variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10            // storage in gigabytes
      engine              = "postgres"    // engine type
      engine_version      = "14"          // engine version
      instance_class      = "db.t3.micro" // rds instance type
      db_name             = "omega_db"    // database name
      skip_final_snapshot = true
      db_username         = "postgres"
      db_password         = "postgres"
      port                = "5432"
    },
    "omega_backend" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t3.small" // the EC2 instance
    },
    "omega_frontend" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t2.micro" // the EC2 instance
    }
  }
}

variable "eip_name" {
  description = "Nom ip fixe"
  type        = string
  default     = "omega_eip_"
}
variable "eip_name_frontend" {
  description = "Nom ip fixe"
  type        = string
  default     = "omega_eip_frontend"
}

variable "rt_omega_backend" {
  description = "toute table for omega backend"
  type        = string
  default     = "0.0.0.0/0"
}
