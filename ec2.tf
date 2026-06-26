# Look up the latest Ubuntu 24.04 LTS AMI dynamically instead of hardcoding
# an AMI ID. AMI IDs are region-specific and change over time as Canonical
# publishes updates — hardcoding one would silently go stale.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Installs Docker and runs the Task Tracker API container automatically
  # on first boot, so the instance is immediately useful once provisioned —
  # no manual SSH step required just to get something running.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker
  EOF

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}
