# VPC
output "vpc_cidr" {
  description = "VPC_CIDR "
  #value       = aws_vpc.main[count.index].cidr_block
  value = concat(aws_vpc.main.*.cidr_block, [""])[0]
}
output "vpc_id" {
  description = "The ID of the VPC"
  #value       = aws_vpc.main[count.index].id
  value = concat(aws_vpc.main.*.id, [""])[0]
}
output "private_subnet_a_ids" {
  description = "List of IDs of privateA subnets"
  value       = aws_subnet.private_a.*.id
}
output "private_subnet_b_ids" {
  description = "List of IDs of privateB subnets"
  value       = aws_subnet.private_b.*.id
}
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = flatten([compact(aws_subnet.private_a.*.id), compact(aws_subnet.private_b.*.id)])
}
output "private_subnet_route_tables" {
  description = "List of IDs of private subnets"
  value       = flatten([aws_route_table.private_a.*.id, aws_route_table.private_b.*.id])
}
output "availability_zones" {
  description = "List of availability zones names for subnets in this vpc"
  value = compact(distinct(flatten([
    aws_subnet.private_a.*.availability_zone,
    aws_subnet.private_b.*.availability_zone,
    aws_subnet.public.*.availability_zone
  ])))
}
output "public_subnet_ids" {
  description = "List of IDs of privateB subnets"
  value       = aws_subnet.public.*.id
}

output "nat_eips" {
  description = "NAT IP addresses"
  value       = try(aws_eip.nat[*].public_ip, "")
}

output "private_subnet_1a_cidr" {
  description = " Private subnet 1A CIDR in Availability Zone 1"
  value       = try(aws_subnet.private_a[0].cidr_block, "")
}

output "private_subnet_1a_id" {
  description = " Private subnet 1A ID in Availability Zone 1"
  value       = try(aws_subnet.private_a[0].id, "")
}

output "private_subnet_1b_cidr" {
  description = " Private subnet 1B CIDR in Availability Zone 1"
  value       = try(aws_subnet.private_b[0].cidr_block, "")
}

output "private_subnet_1b_id" {
  description = " Private subnet 1B ID in Availability Zone 1"
  value       = try(aws_subnet.private_b[0].id, "")
}

output "private_subnet_2a_cidr" {
  description = " Private subnet 2A CIDR in Availability Zone 2"
  value       = try(aws_subnet.private_a[1].cidr_block, "")
}

output "private_subnet_2a_id" {
  description = " Private subnet 2A ID in Availability Zone 2"
  value       = try(aws_subnet.private_a[1].id, "")
}

output "private_subnet_2b_cidr" {
  description = " Private subnet 2B CIDR in Availability Zone 2"
  value       = try(aws_subnet.private_b[1].cidr_block, "")
}

output "private_subnet_2b_id" {
  description = " Private subnet 2B ID in Availability Zone 2"
  value       = try(aws_subnet.private_b[1].id, "")
}

output "private_subnet_3a_cidr" {
  description = " Private subnet 3A CIDR in Availability Zone 3"
  value       = length(aws_subnet.private_a.*.cidr_block) > 2 ? aws_subnet.private_a[2].cidr_block : null
}

output "private_subnet_3a_id" {
  description = " Private subnet 3A ID in Availability Zone 3"
  value       = length(aws_subnet.private_a.*.id) > 2 ? aws_subnet.private_a[2].id : null
}

output "private_subnet_3b_cidr" {
  description = " Private subnet 3B CIDR in Availability Zone 3"
  value       = length(aws_subnet.private_b.*.cidr_block) > 2 ? aws_subnet.private_b[2].cidr_block : null
}

output "private_subnet_3b_id" {
  description = " Private subnet 3B ID in Availability Zone 3"
  value       = length(aws_subnet.private_b.*.id) > 2 ? aws_subnet.private_b[2].id : null
}

output "private_subnet_4a_cidr" {
  description = " Private subnet 4A CIDR in Availability Zone 4"
  value       = length(aws_subnet.private_a.*.cidr_block) > 3 ? aws_subnet.private_a[3].cidr_block : null
}

output "private_subnet_4a_id" {
  description = " Private subnet 4A ID in Availability Zone 4"
  value       = length(aws_subnet.private_a.*.id) > 3 ? aws_subnet.private_a[3].id : null
}

output "private_subnet_4b_cidr" {
  description = " Private subnet 4B CIDR in Availability Zone 4"
  value       = length(aws_subnet.private_b.*.cidr_block) > 3 ? aws_subnet.private_b[3].cidr_block : null
}

output "private_subnet_4b_id" {
  description = " Private subnet 4B ID in Availability Zone 4"
  value       = length(aws_subnet.private_b.*.id) > 3 ? aws_subnet.private_b[3].id : null
}

output "public_subnet_1_cidr" {
  description = " Public subnet 1 CIDR in Availability Zone 1"
  value       = try(aws_subnet.public[0].cidr_block, "")
}

output "public_subnet_1_id" {
  description = " Public subnet 1 ID in Availability Zone 1"
  value       = try(aws_subnet.public[0].id, "")
}

output "public_subnet_2_cidr" {
  description = " Public subnet 2 CIDR in Availability Zone 2"
  value       = try(aws_subnet.public[1].cidr_block, "")
}

output "public_subnet_2_id" {
  description = " Public subnet 2 ID in Availability Zone 2"
  value       = try(aws_subnet.public[1].id, "")
}

output "public_subnet_3_cidr" {
  description = " Public subnet 3 CIDR in Availability Zone 3"
  value       = length(aws_subnet.public.*.cidr_block) > 2 ? aws_subnet.public[2].cidr_block : null
}

output "public_subnet_3_id" {
  description = " Public subnet 3 ID in Availability Zone 3"
  value       = length(aws_subnet.public.*.id) > 2 ? aws_subnet.public[2].id : null
}

output "public_subnet_4_cidr" {
  description = " Public subnet 4 CIDR in Availability Zone 4"
  value       = length(aws_subnet.public.*.cidr_block) > 3 ? aws_subnet.public[3].cidr_block : null
}

output "public_subnet_4_id" {
  description = " Public subnet 4 ID in Availability Zone 4"
  value       = length(aws_subnet.public.*.id) > 3 ? aws_subnet.public[3].id : null
}

output "s3_vpc_endpoint" {
  description = " S3 VPC Endpoint"
  value       = aws_vpc_endpoint.s3.*.id
}

output "private_subnet_1a_route_table" {
  description = " Private subnet 1A route table"
  value       = try(aws_route_table.private_a[0].id, "")
}

output "private_subnet_1b_route_table" {
  description = " Private subnet 1B route table"
  value       = try(aws_route_table.private_b[0].id, "")
}

output "private_subnet_2a_route_table" {
  description = " Private subnet 2A route table"
  value       = try(aws_route_table.private_a[1].id, "")
}

output "private_subnet_2b_route_table" {
  description = " Private subnet 2B route table"
  value       = try(aws_route_table.private_b[1].id, "")
}

output "private_subnet_3a_route_table" {
  description = " Private subnet 3A route table"
  value       = length(aws_route_table.private_a.*.id) > 2 ? aws_route_table.private_a[2].id : null
}

output "private_subnet_3b_route_table" {
  description = " Private subnet 3B route table"
  value       = length(aws_route_table.private_b.*.id) > 2 ? aws_route_table.private_b[2].id : null
}

output "private_subnet_4a_route_table" {
  description = " Private subnet 4A route table"
  value       = length(aws_route_table.private_a.*.id) > 3 ? aws_route_table.private_a[3].id : null
}

output "private_subnet_4b_route_table" {
  description = " Private subnet 4B route table"
  value       = length(aws_route_table.private_b.*.id) > 3 ? aws_route_table.private_b[3].id : null
}

output "public_subnet_route_table" {
  description = " Public subnet route table"
  value       = aws_route_table.public.*.id
}

output "igw_id" {
  description = "ID for IGW attached to public subnets"
  value       = length(aws_internet_gateway.gw) == 1 ? aws_internet_gateway.gw[0].id : ""
}

output "nat_gw_ids" {
  description = "ID's for NAT gateways attached to private subnets"
  value       = length(aws_nat_gateway.nat_gw) > 0 ? aws_nat_gateway.nat_gw[*].id : []
}

output "private_a_nat_routes" {
  description = "Routes for NAT gateways attached to private_a subnets"
  value       = length(aws_route.private_a_nat_gateway[*]) > 0 ? aws_route.private_a_nat_gateway[*].id : []
}

output "private_b_nat_routes" {
  description = "Routes for NAT gateways attached to private_b subnets"
  value       = length(aws_route.private_b_nat_gateway[*]) > 0 ? aws_route.private_b_nat_gateway[*].id : []
}

output "flow_log_id" {
  value       = try(aws_flow_log.flow_logs[0].id, "")
  description = "The Flow Log ID"
}

output "flow_log_arn" {
  value       = try(aws_flow_log.flow_logs[0].arn, "")
  description = "The ARN of the Flow log"
}

output "flow_log_destination" {
  value       = try(aws_flow_log.flow_logs[0].log_destination, "")
  description = "The ARN of the logging destination."
}