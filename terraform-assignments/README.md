# Assignment 1: WordPress on EC2 with Terraform

Deploys a working WordPress site on AWS using only Terraform. After `terraform apply`, the instance bootstraps itself (web server, PHP, database, WordPress) and the site is reachable on the instance's public IP.

## What it builds

- A public subnet in the default VPC
- A security group allowing inbound HTTP (TCP 80) and all outbound traffic
- An EC2 instance (Amazon Linux 2023) running WordPress
- An IAM role and instance profile so the instance can be reached with AWS Systems Manager Session Manager (no SSH port is open)
- A user data script (`wordpress.sh`) that installs and configures everything on first boot

## Files

|File|Purpose|
|---|---|
|`main.tf`|Provider, subnet, security group, IAM, EC2 instance|
|`variables.tf`|Inputs (region, instance type, AMI, database settings)|
|`outputs.tf`|Instance ID, public IP and site URL|
|`wordpress.sh`|User data script run on first boot|
|`terraform.tfvars.example`|Template for the one secret value you must supply|

## How it works

The user data script runs once, as root, on first boot. In order, it:

1. Installs Apache, PHP, MariaDB and supporting packages
2. Downloads and unpacks WordPress
3. Starts MariaDB and waits until it accepts connections
4. Creates the database and a dedicated database user
5. Writes `wp-config.php` with the database details and fresh security salts
6. Copies WordPress into the web root and sets file ownership

The database name, user and password are filled into the script by Terraform's `templatefile()` function, so none of them are hardcoded in the script.

## How to run it

Prerequisites: Terraform, the AWS CLI configured for your account, and an AMI ID for Amazon Linux 2023 in your chosen region (AMI IDs are regional).

bash

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit it and set db_password
terraform init
terraform plan
terraform apply
```

When `apply` finishes, open the `site_url` output in a browser using `http://` (not `https://`). Allow a few minutes for the user data script to finish. Then complete the WordPress installer in the browser.

To tear everything down:

bash

```bash
terraform destroy
```

## Handling the database password

- `db_password` is declared with `sensitive = true` and has no default, so it is hidden in `plan` and `apply` output.
- The real value lives in `terraform.tfvars`, which is listed in `.gitignore` and is never committed.
- The user data script contains only a `${db_password}` placeholder.
- Limitation: Terraform still stores the value in plain text in the state file, and it is present in the instance's user data once deployed. The state file is also git-ignored.

## Lessons learned

- AMI IDs and availability zones belong to one region. An "image not found" error was a region mismatch.
- Terraform removes AWS's default outbound rule from a security group it creates, so an explicit egress rule is needed or the instance cannot download packages.
- A service can be "started" before it is ready, so the script waits for MariaDB before running database commands.
- `sensitive = true` hides a value on screen; it does not encrypt it.

## Possible improvements

- Use AWS Secrets Manager or SSM Parameter Store for the database password, so it never sits in user data or a variable file
- Move the database to Amazon RDS
- Add a domain name and HTTPS (for example certbot, or a load balancer with an ACM certificate)
- Attach an Elastic IP so the address survives a stop and start
- Build a dedicated VPC instead of using the default one
- Bake the setup into an AMI (for example with Packer) for faster, more reliable launches

## Screenshots

See the `screenshots/` folder:

- [ ] WordPress installer page
- [ ] `terraform apply` output showing the outputs section

![[Pasted image 20261122165633.png|524]]
![[Pasted image 20261122170150.png]]