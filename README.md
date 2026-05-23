# Sparklehood - AWS DevOps Engineer internship Assignment

## Overview

This submission covers **Part A only** (Terraform infrastructure on LocalStack). Parts B (Cost Janitor script) and C (design note) are not attempted — I don't yet have the Python/CI skills to complete them honestly, and I'd rather submit what I genuinely understand than code I can't explain.

The Terraform provisions NimbusKart's staging baseline: a VPC with two public subnets, a web-tier security group, two EC2 instances, an S3 log bucket with versioning and lifecycle rules, and one intentionally unattached EBS volume (which Part B would scan as an orphan). The network layer is extracted into a reusable module.

---

## How to run locally

Requires: Docker, Python 3.10+.

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 2. Start LocalStack
docker run --rm -d -p 4566:4566 --name localstack localstack/localstack

# Wait ~10 seconds, then confirm it's healthy
curl -s http://localhost:4566/_localstack/health | python3 -m json.tool

# 3. Install tflocal
pip install terraform-local

# 4. Apply
cd terraform
tflocal init
tflocal apply -auto-approve

# 5. Verify resources
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name}' \
  --output table

aws --endpoint-url=http://localhost:4566 ec2 describe-volumes \
  --query 'Volumes[*].{ID:VolumeId,State:State,Size:Size}' \
  --output table

aws --endpoint-url=http://localhost:4566 s3 ls

# 6. Destroy when done
tflocal destroy -auto-approve
docker stop localstack
```

---

## Architecture

```
LocalStack (Docker)
└── AWS APIs: EC2, S3, STS

Terraform root (terraform/)
├── main.tf          ← EC2 instances, S3 bucket, orphan EBS, provider config
├── variables.tf     ← all tunables with defaults (region, env, CIDRs, etc.)
├── outputs.tf       ← VPC ID, subnet IDs, bucket name
└── modules/
    └── network/     ← VPC, subnets, IGW, route table, security group
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Decisions & deviations

- **SSH CIDR changed from `0.0.0.0/0` to `10.0.0.0/8`** — the spec asked for `0.0.0.0/0` on port 22 but flagged this as a known problem (Section 3.3, FAQ Q4). SSH open to the internet would be flagged by any security scanner as a critical finding. I restricted it to an internal range and made it a variable so it can be overridden per environment.
- **S3 public access block added** — the spec didn't mention it, but leaving an S3 bucket without `block_public_acls = true` is a data-exposure risk. Added it as a separate resource.
- **No EC2 key pair** — the spec didn't include a key name variable. I left a comment in `main.tf` flagging this; in production a `key_name` variable would be required.
- **`skip_credentials_validation` set in provider** — needed for LocalStack to work without real AWS credentials. This block is safe to remove when pointing at real AWS.
- **Orphan EBS volume intentionally missing the `Owner` tag** — so that when Part B is eventually implemented, this single resource triggers both the unattached-volume check and the missing-tags check.

---

## Trade-offs

With more time and skills I would:

1. Complete Part B — the Cost Janitor Python script that scans for the orphaned EBS volume this Terraform deliberately creates.
2. Complete Part C — the design note on multi-cloud extension and IAM scoping.
3. Wire up a GitHub Actions workflow to run `terraform validate` and `terraform fmt -check` on every PR.
4. Add a `terraform.tfvars.example` file with safe example values for each variable.

---

## AI usage disclosure

- Used Claude (claude.ai) to help generate the initial Terraform structure and module layout.
- I reviewed every resource block, understood what each one does, and adjusted the SSH CIDR and S3 public-access block based on my own judgment.
- I did not use AI for Parts B or C because I don't have the background to verify or explain that code — and submitting code I can't stand behind isn't something I'm willing to do.
