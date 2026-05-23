# Submission — DevOps Engineer Assignment

**Candidate name:** [YOUR NAME]
**Email:** [YOUR EMAIL]
**Date submitted:** [DATE]
**Hours spent (approximate):** [X hours]

## Deliverables checklist

- [*] Part A: Terraform code under /terraform applies cleanly on LocalStack
- [*] Part A: `terraform validate` and `terraform fmt -check` both pass
- [ ] Part B: Janitor script runs in --dry-run mode and produces report.json — **NOT ATTEMPTED**
- [ ] Part B: GitHub Actions workflow runs green on a fresh PR — **NOT ATTEMPTED**
- [ ] Part B: --delete mode respects Protected=true tag — **NOT ATTEMPTED**
- [ ] Part C: DESIGN.md is present and within 2 pages — **NOT ATTEMPTED**
- [ ] Walkthrough video link below is accessible (unlisted is fine)

## Walkthrough video

Link (Loom / YouTube unlisted / Google Drive): [ADD LINK BEFORE SUBMITTING]
Length: max 5 minutes

## Sample report

Not applicable — Part B not attempted.

## Known limitations

- Parts B and C are not submitted. I don't have sufficient Python experience to complete them honestly, and I'd rather be transparent about that than submit code I cannot explain or defend in a follow-up interview.
- No key pair variable on EC2 instances — flagged in main.tf with a comment.
- Static AMI ID used (LocalStack accepts any value; a real deployment would use a data source to look up the latest Amazon Linux AMI).

## AI usage disclosure

- Used Claude (claude.ai) to help scaffold the Terraform module structure.
- Reviewed all generated code, understood each resource block, and made deliberate changes (SSH CIDR restriction, S3 public access block) based on my own judgment.
- Did not use AI to generate Parts B or C — I have no way to verify or explain code in areas I don't know, and I won't submit work I can't stand behind.
