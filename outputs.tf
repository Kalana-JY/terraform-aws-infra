output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_storage.bucket
}

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the instance"
  value       = "ssh -i <your-key>.pem ubuntu@${aws_instance.app_server.public_ip}"
}
