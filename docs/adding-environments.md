# Adding New Environments

This guide explains how to add a new environment (e.g., `dev`, `qa`, `uat`) to your infrastructure and how to manage the Shared ECR strategy.

## 1. Concept: Shared ECR Strategy

We use a **"Build Once, Deploy Anywhere"** strategy.
- **One Environment** is designated as the **"Owner"**. It creates the ECR repository.
- **All Other Environments** are **"Consumers"**. They read and use the existing repository.

Currently, **`dev`** is the Owner. `staging` and `prod` are Consumers.

## 2. Adding a New Environment

To add a new environment (e.g., `qa`):

### 2.1 Update Service Template Workflows
Edit `.github/workflows/deploy.yml` and `.github/workflows/destroy.yml` to add the new environment to the input options:

```yaml
inputs:
  environment:
    type: choice
    options:
      - dev
      - staging
      - prod
      - qa  # <--- Add this
```

### 2.2 Update Platform Template Workflows
Repeat the same step for the `aws-fargate-platform-template` repository.

### 2.3 Deploy
1.  **Deploy Platform**: Run the Platform `deploy` workflow, selecting `qa`.
2.  **Deploy Service**: Run the Service `deploy` workflow, selecting `qa`.

## 3. Changing the ECR Owner

If you want to change which environment creates the ECR repository (e.g., from `staging` to `dev`), you must update the logic in `terraform/main.tf` of the Service Template.

**Current Logic:**
```hcl
create_ecr = var.environment == "dev"
```

### ⚠️ Critical Migration Warning
If you change the owner, you must ensure the **new owner** is deployed **before** the old owner is destroyed, OR follow a clean destruction path.

**Recommended Migration Path (Clean Slate):**
1.  **Destroy Consumers**: Destroy `prod`, `staging`, etc.
2.  **Destroy Old Owner**: Destroy the old owner environment (e.g., `staging`). **This deletes the ECR repo.**
3.  **Deploy New Owner**: Deploy the new owner (e.g., `dev`). **This creates a new ECR repo.**
4.  **Deploy Consumers**: Re-deploy `staging`, `prod`.
