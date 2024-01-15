# GCP Infrastructure Deployment

This project uses Terraform to deploy a basic Google Cloud Platform (GCP) infrastructure. The infrastructure includes a Virtual Machine, a Cloud Storage bucket, and a Cloud SQL database.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have installed [Terraform](https://www.terraform.io/downloads.html).
* You have a Google Cloud Platform (GCP) account.

## Using GCP Infrastructure Deployment

To use GCP Infrastructure Deployment, follow these steps:

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Update the 'terraform.tfvars' file with your GCP credentials and desired configurations. If you're unsure how to obtain your GCP credentials, follow [this guide](https://cloud.google.com/docs/authentication/getting-started).
4. Initialize your Terraform workspace, which will download the provider plugins for GCP:

    ```bash
    terraform init
    ```

5. Generate a plan for your infrastructure changes:

    ```bash
    terraform plan
    ```

6. Apply the changes to reach the desired state of the infrastructure:

    ```bash
    terraform apply
    ```

## Project Structure

* `terraform/`: This directory contains the Terraform scripts for the infrastructure.
* `README.md`: This file contains project documentation and instructions.

## Contact

If you want to contact me, you can reach me at `coop@cmandersen.net`.

## License

This project uses the MIT License.