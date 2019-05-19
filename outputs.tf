output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "public_subnets" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "private_subnets" {
  value = "${join(",", aws_subnet.private.*.id)}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_ids" {
  value = "${join(",", aws_route_table.private.*.id)}"
}

output "nat_eips" {
  value = "${join(",", aws_eip.nat.*.public_ip)}"
}

/* output "vpc_cidr_checker_result" {
  value = "${data.http.vpc-cidr-check.body}"
} */

/* output "rds_db_subnet_group" {
  value = "${aws_db_subnet_group.rds_db_subnet_group.id}"
} */
