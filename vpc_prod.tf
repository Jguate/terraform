# VPCs
resource "aws_vpc" "vpc-prod-gt" {
  cidr_block = "10.15.0.0/16"
}

resource "aws_vpc" "vpc-prod-hn" {
  cidr_block = "10.16.0.0/16"
}

resource "aws_vpc" "vpc-shared-prod" {
  cidr_block = "10.12.0.0/16"
}

# Subnets
resource "aws_subnet" "vpc-prod-gt-sub-a" {
  vpc_id     = "aws_vpc.vpc-prod-gt.id"
  cidr_block = "10.15.1.0/24"
  availability_zone = "us-east-1a"
}

/*si necesitamos crear subnet en otra AZ*/
resource "aws_subnet" "vpc-prod-gt-sub-b" {
  vpc_id     = "aws_vpc.vpc-prod-gt.id"
  cidr_block = "10.15.2.0/24"
  availability_zone = "us-east-1b"
}


resource "aws_subnet" "vpc-prod-hn-sub-a" {
  vpc_id     = "aws_vpc.vpc-prod-hn.id"
  cidr_block = "10.16.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "vpc-shared-prod-sub-a" {
  vpc_id     = "aws_vpc.vpc-shared-prod.id"
  cidr_block = "10.12.1.0/24"
  availability_zone = "us-east-1a"
}


# Main Route Tables Associations
## Forcing our Route Tables to be the main ones for our VPCs,
## otherwise AWS automatically will create a main Route Table
## for each VPC, leaving our own Route Tables as secondary

resource "aws_main_route_table_association" "main-rt-vpc-prod-gt" {
  vpc_id         = "aws_vpc.vpc-prod-gt.id"
  route_table_id = "aws_route_table.vpc-prod-gt-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-prod-hn" {
  vpc_id         = "aws_vpc.vpc-prod-hn.id"
  route_table_id = "aws_route_table.vpc-prod-hn-rtb.id"
}

resource "aws_main_route_table_association" "main-rt-vpc-shared-prod" {
  vpc_id         = "aws_vpc.vpc-shared-prod.id"
  route_table_id = "aws_route_table.vpc-shared-prod-rtb.id"
}


# Transit Gateway
## Default association and propagation are disabled since our scenario involves
## a more elaborated setup where

resource "aws_ec2_transit_gateway" "prod-tgw" {
  description                     = "Transit Gateway for prod"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}


# Route Tables
## Usually unecessary to explicitly create a Route Table in Terraform
## since AWS automatically creates and assigns a 'Main Route Table'
## whenever a VPC is created. However, in a Transit Gateway scenario,
## Route Tables are explicitly created so an extra route to the
## Transit Gateway could be defined

resource "aws_route_table" "vpc-prod-gt-rtb" {
  vpc_id = "aws_vpc.vpc-prod-gt.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  }

  tags = {
    Name       = "vpc-prod-gt-rtb"
    env        = "prod-gt"
  }
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}

resource "aws_route_table" "vpc-prod-hn-rtb" {
  vpc_id = "aws_vpc.vpc-prod-hn.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  }

  tags = {
    Name       = "vpc-prod-hn-rtb"
    env        = "prod-hn"
  }
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}

resource "aws_route_table" "vpc-shared-prod-rtb" {
  vpc_id = "aws_vpc.vpc-shared-prod.id"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  }

  tags = {
    Name       = "vpc-shared-prod-rtb"
    env        = "shared"
  }
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}


# VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-prod-gt" {
  /*seleccionar multiples subnets*/
  subnet_ids         = ["aws_subnet.vpc-prod-gt-sub-a.id", "aws_subnet.vpc-prod-gt-sub-b.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  vpc_id             = "aws_vpc.vpc-prod-gt.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-prod-hn" {
  subnet_ids         = ["aws_subnet.vpc-prod-hn-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  vpc_id             = "aws_vpc.vpc-prod-hn.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-shared-prod" {
  subnet_ids         = ["aws_subnet.vpc-shared-prod-sub-a.id"]
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  vpc_id             = "aws_vpc.vpc-shared-prod.id"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}


# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-dev-gt-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-dev-hn-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}


resource "aws_ec2_transit_gateway_route_table" "tgw-shared-rt" {
  transit_gateway_id = "aws_ec2_transit_gateway.prod-tgw.id"
  
  depends_on = ["aws_ec2_transit_gateway.prod-tgw"]
}


# Route Tables Associations
## This is the link between a VPC (already symbolized with its attachment to the Transit Gateway)
##  and the Route Table the VPC's packet will hit when they arrive into the Transit Gateway.
## The Route Tables Associations do not represent the actual routes the packets are routed to.
## These are defined in the Route Tables Propagations section below.

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-prod-gt-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-prod-hn-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-shared-prod-assoc" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared-prod.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}

# Route Tables Propagations
## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-gt-to-vpc-prod-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-gt-to-vpc-shared-prod" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared-prod.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-gt-rt.id"
}



resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-hn-to-vpc-prod-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-hn-to-vpc-shared-prod" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-shared-prod.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-dev-hn-rt.id"
}



resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-prod-gt" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-gt.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-prod-hn" {
  transit_gateway_attachment_id  = "aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-prod-hn.id"
  transit_gateway_route_table_id = "aws_ec2_transit_gateway_route_table.tgw-shared-rt.id"
}





