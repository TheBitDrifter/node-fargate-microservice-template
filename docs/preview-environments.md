# Preview Environments

Preview environments are ephemeral, full-stack deployments of your service created dynamically from feature branches. They allow you to test changes in a real cloud environment before merging.

## How it Works

1.  **Shared Infrastructure**: Previews run on the **Dev** platform (sharing the VPC, Cluster, and ALB).
2.  **Dynamic Naming**: The service is named `preview-<branch-name>` (e.g., `preview-feature-login`).
3.  **Isolation**: Each preview has its own Terraform state file at `services/preview/<service-alias>.tfstate`.
4.  **Shared ECR**: Previews use the existing `dev` ECR repository. They do **not** create new repositories.

## Usage

### Deploying a Preview
1.  Go to **Actions** > **Deploy Preview Environment**.
2.  Select your feature branch.
3.  Enter **Expiry Days** (e.g., `1` for 24 hours).
4.  Click **Run workflow**.

**URL**: Your service will be available at `https://<dev-alb-url>/preview-<branch-name>/`

### Destroying a Preview
Previews should be cleaned up when no longer needed.

1.  Go to **Actions** > **Destroy Preview Environment**.
2.  Enter the **Branch Name** you want to destroy (e.g., `feature/login`).
3.  Click **Run workflow**.

## Expiry Policy (V1)
Currently, expiry is **manual**. The "Expiry Days" input is for tracking purposes. You must manually run the Destroy workflow.
*Future V2*: An automated reaper will delete environments based on the expiry tag.
