variable "region_aws" {
  description = "Region AWS"
  type        = string
  default     = "eu-west-3"
}

variable "access_key_aws" {
  description = "access_key_aws"
  type        = string
  //default     = ""
  default = ""
}

variable "secret_key_aws" {
  description = "secret_key_aws"
  type        = string
  default     = ""
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

variable "settings_gr_ec2" {
  description = "Configuration settings de groupe Ec2"
  type        = map(any)
  default = {
    ingress_1 = {
      des          = "Allow all trafic through HTTP"
      inport       = "80"
      outport      = "80"
      protocol     = "tcp"
      cidr_blocks  = "0.0.0.0/0"
    },
    ingress_2 = {
      des          = "Allow SSH from my computer"
      inport       = "20"
      outport      = "20"
      protocol     = "tcp"
      cidr_blocks  = "0.0.0.0/0"
    }
  }
}
variable "sg_omega_name_frontend" {
  description = "Nom securité groupe omega_frontend"
  type        = string
  default     = "sg_omega_frontend"
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
      instance_type = "t2.micro" // the EC2 instance
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
