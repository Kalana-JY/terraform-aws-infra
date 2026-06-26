# Terraform on AWS — Provisioning Infrastructure as Code

**Project 4** in the DevOps learning series. This provisions real AWS
infrastructure — an EC2 instance, a security group, and an S3 bucket —
entirely from Terraform code, rather than clicking through the AWS console
(as Project 3's Jenkins server was set up).

## Why this project exists

Project 3 involved manually clicking through the EC2 console to launch an
instance. That works, but it isn't repeatable, reviewable, or version
controlled — if the instance gets deleted, recreating it means remembering
every setting by hand. Terraform fixes that: the entire infrastructure is
defined in code, so spinning up an identical environment is one command, and
the configuration itself can be reviewed, diffed, and version-controlled
like any other code.

## What gets provisioned

- **EC2 instance** (`t3.micro`, free-tier eligible) running Ubuntu 24.04,
  with Docker installed automatically via a `user_data` boot script
- **Security group** allowing SSH (port 22) and the app port (3000), both
  restricted to your IP only
- **S3 bucket** with public access blocked and versioning enabled, intended
  for storing deployment artifacts or backups in later projects

The EC2 AMI is looked up dynamically via a Terraform data source rather than
hardcoded, so this configuration won't silently break as Canonical publishes
newer Ubuntu 24.04 image builds.

## File structure

```
.
├── provider.tf               # AWS provider + Terraform version constraints
├── variables.tf               # Input variables (region, instance type, IP, etc.)
├── security_group.tf          # Firewall rules
├── ec2.tf                      # EC2 instance + AMI lookup
├── s3.tf                        # S3 bucket + security settings
├── outputs.tf                  # Values printed after apply (IP, bucket name, etc.)
└── terraform.tfvars.example   # Template for your own variable values
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
  (`aws configure`) for an IAM user with EC2 and S3 permissions
- An EC2 key pair created manually in the AWS Console (**EC2 → Key Pairs →
  Create key pair**, type RSA, format `.pem`). Terraform references this key
  pair by name only — the private key file stays on your machine and is
  never generated, transmitted, or stored by Terraform. This is deliberate:
  letting Terraform generate a key pair (via the `tls_private_key` resource)
  would write the private key into the state file in plaintext, which is a
  real security risk if that state file is ever shared or leaked.
- An AWS account with free-tier eligibility (this is designed to stay within
  free-tier limits, but **always double check the AWS Billing dashboard**)

## Usage

1. Copy the example variables file and fill in your own values:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   At minimum, set:
   - `my_ip` — your public IP in CIDR form (get it from
     [checkip.amazonaws.com](https://checkip.amazonaws.com), then add `/32`)
   - `key_pair_name` — the name of the EC2 key pair you created manually
   - `bucket_suffix` — any unique string, since S3 bucket names must be
     globally unique across all AWS accounts

2. Initialize Terraform (downloads the AWS provider plugin):

   ```bash
   terraform init
   ```

3. Preview what Terraform will create, **without actually creating anything**:

   ```bash
   terraform plan
   ```

4. Apply — this actually provisions the resources in AWS:

   ```bash
   terraform apply
   ```

   Terraform will show the plan again and ask for confirmation
   (`yes`) before making any real changes.

5. Once applied, Terraform prints outputs including the instance's public IP
   and a ready-to-use SSH command.

6. **When you're done experimenting, tear it down** to avoid any unexpected
   charges:

   ```bash
   terraform destroy
   ```

## A note on safety

`my_ip` restricts SSH and app access to your IP only — the same lesson
learned the hard way in Project 3, where a security group locked to "My IP"
silently breaks access whenever your network changes. If you ever can't
connect after your IP changes, update `terraform.tfvars` and re-run
`terraform apply` — Terraform will update just the security group rule
without touching the running instance.

`terraform.tfvars` and all `*.tfstate` files are gitignored. State files in
particular can contain sensitive data and should never be committed — in a
team setting, state is typically stored remotely (e.g. an S3 backend with
state locking), which is a natural next step beyond this learning project.

## Real issues hit building this

- **AMI name patterns change over time.** The original AMI filter targeted
  `ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*`, which returned
  zero results. Querying `aws ec2 describe-images` directly showed Canonical
  had moved to a `hvm-ssd-gp3` path segment instead of `hvm-ssd` — a real
  example of why hardcoding exact AMI names (or even exact filter patterns
  copied from older tutorials) is fragile. Always verify against
  `aws ec2 describe-images` rather than trusting a filter pattern blindly.
- **Forgetting `key_name` produces a "successful" apply with an
  inaccessible instance.** Terraform won't warn you if an EC2 instance has
  no key pair attached — it's valid configuration, it just means there's no
  way to SSH in afterward. Worth deliberately checking for this before
  considering a deployment done.
- **Changing `key_name` forces instance replacement, not an in-place
  update.** AWS doesn't support changing a running instance's key pair, so
  Terraform's plan correctly shows this as `-/+` (destroy and recreate)
  rather than a simple update — a useful example of the difference between
  attributes Terraform can update in place versus ones that force
  replacement.

## What's next in this series

1. ✅ **Dockerize a multi-tier app**
2. ✅ **CI/CD pipeline with GitHub Actions**
3. ✅ **Same pipeline rebuilt in Jenkins** (self-hosted on AWS EC2)
4. ✅ **Provision AWS infrastructure with Terraform** (this repo)
5. 🔜 Configure provisioned servers with Ansible
6. 🔜 Deploy to Kubernetes (Minikube/Kind)
7. 🔜 Capstone: full GitHub Actions → Kubernetes deployment pipeline

## License

MIT
