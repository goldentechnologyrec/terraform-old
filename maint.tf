/*
Création infrastructure OMEGA as code
avec Terraform
*/
#Configuration provider AWS
provider "aws" {
    region = "${var.region_aws}"
    access_key = "${var.access_key_aws}"
    secret_key = "${var.secret_key_aws}"
}

#Creation VPC REC
resource "aws_vpc" "vpc_rec" {
    cidr_block ="${var.vpc_rec_cidr}"
    # We want DNS hostnames enabled for this VPC
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_rec_name}"
    }
}

//Creation intenet gateway et l attacher au VPC

resource "aws_internet_gateway" "rec_igw" {
    //Attacher VPC a igw
    vpc_id = aws_vpc.vpc_rec.id
    //tags
     tags = {
    Name = "${var.gateway_name}"
  }
}

//Creation de groupe subnet publique basé sur la variable subnet_count.public

resource "aws_subnet" "omega_public_subnet" {
    count = var.subnet_count.public
    vpc_id = aws_vpc.vpc_rec.id
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
    Name = "${var.group_public_subnets_name}${count.index}"
  }

}

//Creation de groupe subnet privee basé sur la variable subnet_count.public

resource "aws_subnet" "omega_private_subnet" {
    count = var.subnet_count.private
    vpc_id = aws_vpc.vpc_rec.id
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
    Name = "${var.group_private_subnets_name}${count.index}"
  }

}

//Creation route table public

resource "aws_route_table" "omega_public_rt" {
vpc_id= aws_vpc.vpc_rec.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rec_igw.id
}
}

//Associer route table > subnet publique

resource "aws_route_table_association" "public" {
    count = var.subnet_count.public
    route_table_id = aws_route_table.omega_public_rt.id
    subnet_id = aws_subnet.omega_public_subnet[count.index].id
}

//Creation route table prive

resource "aws_route_table" "omega_private_rt" {
vpc_id= aws_vpc.vpc_rec.id
}

//Associer route table > subnet prive

resource "aws_route_table_association" "private" {
    count = var.subnet_count.private
    route_table_id = aws_route_table.omega_private_rt.id
    subnet_id = aws_subnet.omega_private_subnet[count.index].id
}

//Creation groupe securite EC2

resource "aws_security_group" "omega_backend_sg" {
    name = "omega_backend_sg"
    description = "Groupe securite omega"
    vpc_id = aws_vpc.vpc_rec.id

    ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "${var.sg_omega_backend_name}"
  }

}

//Creation groupe securite RDS

resource "aws_security_group" "omega_db_sg" {
    name = "omega_db_sg"
    description = "Groupe securite omega db"
    vpc_id = aws_vpc.vpc_rec.id

ingress {
    description     = "Allow postgresdatabase traffic from only the web sg"
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [aws_security_group.omega_backend_sg.id]
  }
   tags = {
    Name = "${var.sg_omega_db_name}"
  }
}

//Création groupe subnet RDS "omega_db_subnet_group"

resource "aws_db_subnet_group" "omega_db_subnet_group" {
  //name ="${var.omega_db_subnet_gr_name}"
  description ="Groupe securité subnet"
  subnet_ids  = [for subnet in aws_subnet.omega_private_subnet : subnet.id]
  tags = {
    Name = "${var.omega_db_subnet_gr_name}"
  }
}

//Création base RDS "omega_database"

resource "aws_db_instance" "omega_database" {
 identifier = "rds-postgres"
 allocated_storage = "${var.settings.database.allocated_storage}"
 engine = "${var.settings.database.engine}"
 engine_version = "${var.settings.database.engine_version}"
 instance_class = "${var.settings.database.instance_class}"
 db_name = "${var.settings.database.db_name}"
 username = "${var.settings.database.db_username}"
 password = "${var.settings.database.db_password}"
 db_subnet_group_name = aws_db_subnet_group.omega_db_subnet_group.id
 vpc_security_group_ids = [aws_security_group.omega_db_sg.id]
 skip_final_snapshot = "${var.settings.database.skip_final_snapshot}"
 tags = {
    Name = "${var.settings.database.db_name}"
  }
}

//Création key_pair

resource "tls_private_key" "priv_omega_backend_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "priv_omega_backend_key_pair" {
  key_name = "omega_backend_key"
  public_key =tls_private_key.priv_omega_backend_key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.priv_omega_backend_key.private_key_pem}' > /home/omega/omega_backend_key.pem"
  }
}

//Création instace EC2 omega_backend

resource "aws_instance" "omega_backend" {
  ami = "ami-07e67bd6b5d9fd892"
  count = "${var.settings.omega_backend.count}"
  instance_type = "${var.settings.omega_backend.instance_type}"
  key_name = aws_key_pair.priv_omega_backend_key_pair.key_name
  subnet_id = aws_subnet.omega_public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.omega_db_sg.id]
  tags = {
    Name = "omega_backend"
  }
}

//Reserver IP fixe

resource "aws_eip" "omega_eip" {
  count = "${var.settings.omega_backend.count}"
  instance = aws_instance.omega_backend[count.index].id
  domain = "standard"
  tags = {
    Name = "${var.eip_name}${count.index}"
  }
}
