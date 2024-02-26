resource "aws_route_table" "default-rt" {
        vpc_id = "${aws_vpc.default-vpc.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "igw-098a469ded2c97655"
        }
        route {
                cidr_block = "10.10.1.0/24"
                vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
        }

}
