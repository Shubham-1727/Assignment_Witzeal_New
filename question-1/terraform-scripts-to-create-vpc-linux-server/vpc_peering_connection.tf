resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id = aws_vpc.default-vpc.id
  peer_vpc_id = aws_vpc.custom-vpc.id
  tags = {
    Name = "VPC-Peering"
  }
}
