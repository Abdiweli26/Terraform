# Assignment 2: EC2 deployment with cloud-init

Uses Terraform to launch an EC2 instance and a cloud-init file to configure it on first boot. The instance comes online fully configured, with no manual steps.

## What it builds

- A public subnet in the default VPC
- A security group allowing inbound HTTP (TCP 80) and all outbound traffic
- An EC2 instance (Amazon Linux 2023)
- A cloud-init file (`cloudinit.yml`) passed to the instance through Terraform's `user_data` argument, which installs and starts Nginx

## Files

|File|Purpose|
|---|---|
|`main.tf`|Provider, subnet, security group, EC2 instance|
|`variables.tf`|Inputs (region, instance type, AMI, and so on)|
|`outputs.tf`|Instance ID, public IP and site URL|
|`cloudinit.yml`|The cloud-init configuration|

## How the cloud-init file works

`cloudinit.yml` starts with `#cloud-config`, which tells cloud-init to treat the file as configuration (as opposed to a shell script). It uses these modules:

|Key|What it does|
|---|---|
|`package_update: true`|Refreshes the package index before installing|
|`packages`|Installs Nginx using the machine's package manager|
|`runcmd`|Enables Nginx at boot and starts it now (`systemctl enable --now nginx`)|

<!-- TODO: if you add a custom page with the write-files module, describe it here. -->

Terraform passes the file to the instance with:

hcl

```hcl
user_data = file("${path.module}/cloudinit.yml")
```

At first boot, cloud-init fetches this data from the EC2 metadata service and applies it.

## How to run it

Prerequisites: Terraform, the AWS CLI configured for your account, and an Amazon Linux 2023 AMI ID for your chosen region.

bash

```bash
terraform init
terraform plan
terraform apply
```

When `apply` finishes, open the `site_url` output in a browser using `http://` (not `https://`). It takes a minute or two for cloud-init to finish.

To tear everything down:

bash

```bash
terraform destroy
```

## Verifying it worked

From a Session Manager or Instance Connect shell on the instance:

bash

```bash
cloud-init status --long       # cloud-init finished without errors
rpm -q nginx                   # Nginx is installed
systemctl is-active nginx      # Nginx is running
systemctl is-enabled nginx     # Nginx starts on every boot
curl -I http://localhost       # the web server answers
```

Logs for troubleshooting: `/var/log/cloud-init.log` and `/var/log/cloud-init-output.log`.

## Design decisions

- **`packages` instead of installing in `runcmd`:** the module is declarative and handles the package manager for me.
- **`package_update` on, `package_upgrade` off:** a fresh index is cheap, while upgrading every installed package slows boot and makes the result vary between runs.
- **`systemctl enable --now`:** one command enables the service for future boots and starts it for this one.
- **No domain name:** the site is served on the instance's public IP, which is enough for this assignment.

## Lessons learned

- A cloud-init status of `done` means cloud-init finished, not that every key did what I intended. Unknown or misspelled keys are skipped without an error.
- `runcmd` writes commands into a script that a separate module runs in the final boot stage, so ordering depends on the boot stages.
- Loading a bare IP over `https://` goes to port 443, where nothing is listening. Use `http://`.
- Cloud-init, Terraform and the datasource are separate layers: Terraform delivers the file, AWS stores it, and cloud-init applies it on the instance.

## Possible improvements

- Serve a custom page, or a custom Nginx server block, with the write-files module
- Add a domain name and HTTPS
- Use an Elastic IP so the address survives a stop and start
- Validate `cloudinit.yml` against the cloud-init schema as part of a pipeline before applying

## Screenshots

See the `screenshots/` folder:

- [ ] The page loading from the public IP
- [ ] `terraform apply` output showing the outputs section
- [ ] Output of `cloud-init status --long` and `systemctl is-active nginx



![[Pasted image 20261122173451.png]]
![[Pasted image 20261122171004.png]]