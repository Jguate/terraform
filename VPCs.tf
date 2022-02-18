# VPCs
resource "aws_vpc" "vpc-dev-gt" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_vpc" "vpc-test-gt" {
  cidr_block = "10.11.0.0/16"
}

resource "aws_vpc" "vpc-shared" {
  cidr_block = "10.12.0.0/16"
}

resource "aws_vpc" "vpc-dev-hn" {
  cidr_block = "10.13.0.0/16"
}

resource "aws_vpc" "vpc-test-hn" {
  cidr_block = "10.14.0.0/16"
}

# Subnets
resource "aws_subnet" "vpc-dev-gt-sub-a" {
  vpc_id     = "aws_vpc.vpc-dev-gt.id"
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "vpc-dev-gt-sub-b" {
  vpc_id     = "aws_vpc.vpc-dev-gt.id"
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1b"
}



resource "aws_subnet" "vpc-test-gt-sub-a" {
  vpc_id     = "aws_vpc.vpc-test-gt.id"
  cidr_block = "10.11.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "vpc-shared-sub-a" {
  vpc_id     = "aws_vpc.vpc-shared.id"
  cidr_block = "10.12.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "vpc-dev-hn-sub-a" {
  vpc_id     = "aws_vpc.vpc-dev-hn.id"
  cidr_block = "10.13.1.0/24"
  availability_zone = "us-east-1a"
}


resource "aws_subnet" "vpc-test-hn-sub-a" {
  vpc_id     = "aws_vpc.vpc-test-hn.id"
  cidr_block = "10.14.1.0/24"
  availability_zone = "us-east-1a"
}

# Main Route Tables Associations
## Forcing our Route Tables to be the main ones for our VPCs,
## otherwise AWS automatically will create a main Route Table
## for each VPC, leaving our own Route Tables as secondary

resource "aws_main_route_table_association" "main-rt-vpc-dev-gt" {
  vpc_id         = "aws_vpc.vpc-dev-gt.id"
  route_table_id = "aws_route_table.vpc-dev-gt-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-test-gt" {
  vpc_id         = "aws_vpc.vpc-test-gt.id"
  route_table_id = "aws_route_table.vpc-test-gt-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-shared" {
  vpc_id         = "aws_vpc.vpc-shared.id"
  route_table_id = "aws_route_table.vpc-shared-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-dev-hn" {
  vpc_id         = "aws_vpc.vpc-dev-hn.id"
  route_table_id = "aws_route_table.vpc-dev-hn-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-test-hn" {
  vpc_id         = "aws_vpc.vpc-test-hn.id"
  route_table_id = "aws_route_table.vpc-test-hn-rtb.id"
}

# Transit Gateway
## Default association and propagation are disabled since our scenario involves
## a more elaborated setup where
resource "aws_ec2_transit_gateway" "test-dev-tgw" {
  description                     = "Transit Gateway for dev and test"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}

# Route Tables
## Usually unecessary to explicitly create a Route Table in Terraform
## since AWS automatically creates and assigns a 'Main Route Table'
## whenever a VPC is created. However, in a Transit Gateway scenario,
## Route Tables are explicitly created so an extra route to the
## Transit Gateway could be defined

/*Route tables para cada VPC que cuando apunten a 10.0.0.0/8 se rediriccion al TGW*/

resource "aws_route_table" "vpc-dev-gt-rtb" {
  vpc_id = "aws_vpc.vpc-dev-gt.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  }

  tags = {
    Name       = "vpc-dev-gt-rtb"
    env        = "dev"
  }
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_route_table" "vpc-test-gt-rtb" {
  vpc_id = "aws_vpc.vpc-test-gt.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  }

  tags = {
    Name       = "vpc-test-gt-rtb"
    env        = "test"
  }
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_route_table" "vpc-shared-rtb" {
  vpc_id = "aws_vpc.vpc-shared.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  }

/*
#una route_table puede tener multiples rutas:
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.vpc-shared-igw.id"
  }
*/

  tags = {
    Name       = "vpc-shared-rtb"
    env        = "shared"
  }
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}


resource "aws_route_table" "vpc-dev-hn-rtb" {
  vpc_id = "aws_vpc.vpc-dev-hn.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  }

  tags = {
    Name       = "vpc-dev-hn-rtb"
    env        = "dev"
  }
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_route_table" "vpc-test-hn-rtb" {
  vpc_id = "aws_vpc.vpc-test-hn.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  }

  tags = {
    Name       = "vpc-test-hn-rtb"
    env        = "test"
  }
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}





# VPC attachment

/*Seleccionamos las subnets que van utilizar el attachment, el Transit gateway y VPC al que pertenecen.*/

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-dev-gt" {
  /*seleccionar multiples subnets*/
  subnet_ids         = ["aws_subnet.vpc-dev-gt-sub-a.id", "aws_subnet.vpc-dev-gt-sub-b.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  vpc_id             = "aws_vpc.vpc-dev-gt.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-test-gt" {
  subnet_ids         = ["aws_subnet.vpc-test-gt-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  vpc_id             = "aws_vpc.vpc-test-gt.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-shared" {
  subnet_ids         = ["aws_subnet.vpc-shared-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  vpc_id             = "aws_vpc.vpc-shared.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}


resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-dev-hn" {
  subnet_ids         = ["aws_subnet.vpc-dev-hn-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  vpc_id             = "aws_vpc.vpc-dev-hn.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-test-hn" {
  subnet_ids         = ["aws_subnet.vpc-test-hn-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  vpc_id             = "aws_vpc.vpc-test-hn.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

# Route Tables


resource "aws_ec2_transit_gateway_route_table" "tgw-dev-gt-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-test-gt-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-shared-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-dev-hn-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-test-hn-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.test-dev-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.test-dev-tgw"]
}

# Route Tables Associations
## This is the link between a VPC (already symbolized with its attachment to the Transit Gateway)
##  and the Route Table the VPC's packet will hit when they arrive into the Transit Gateway.
## The Route Tables Associations do not represent the actual routes the packets are routed to.
## These are defined in the Route Tables Propagations section below.

/*Vinculamos route tables con el attachment*/

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-dev-gt-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-test-gt-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-gt-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-shared-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}


resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-dev-hn-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-test-hn-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-hn-rt.id"
}


# Route Tables Propagations
## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-gt-to-vpc-dev-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-gt-to-vpc-shared" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}



resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-test-gt-to-vpc-test-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-gt-rt.id"
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-test-gt-to-vpc-shared" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-gt-rt.id"
}

/*VPC shared puede acceder tanto test como dev de guatemala*/
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-dev-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-test-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}

/*VPC shared puede acceder tanto test como dev de honduras*/
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-dev-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-test-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}



/*Comunicacion entre dev y shared de hn*/

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-hn-to-vpc-dev-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-dev-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-hn-to-vpc-shared" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}



/*Comunicacion entre test y shared de hn*/
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-test-hn-to-vpc-test-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-test-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-hn-rt.id"
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-test-hn-to-vpc-shared" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-test-hn-rt.id"
}

