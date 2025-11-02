# Entra ID Conditional Access as Code (Terraform)

This project manages Microsoft Entra ID Conditional Access (CA) policies and
Named Locations using Terraform.

This framework is designed to be robust, secure, and pipeline-ready by using a
remote backend, explicit dependency management, and module validation.

## Features

* **Modular:** A clean separation between reusable logic (`modules`) and your
    specific configurations (`policies.tf`, `locations.tf`).
* **Robust State:** Uses an Azure Storage Account for remote state, enabling
    team collaboration and preventing state file loss.
* **Dependency-Aware:** Uses `depends_on` to ensure resources are created and
    destroyed in the correct order, preventing common API errors.
* **Validated:** Modules include validation rules to catch typos (e.g., in IP
    addresses or country codes) *before* you run `terraform plan`.
* **Protected:** Includes `lifecycle { prevent_destroy = true }` on the most
    critical policy (Block Legacy Auth) to prevent accidental deletion.

---

## Prerequisites

1.  **Terraform:** Version 1.0 or newer.
2.  **Azure CLI:** Installed.
3.  **Azure Storage Account:** You must create a Storage Account and a Blob
    Container (e.g., named `tfstate`) to store the remote state.
4.  **Service Principal (for Pipelines):** For automation, create a Service
    Principal with these **Microsoft Graph (Application)** API permissions:
    * `Policy.ReadWrite.ConditionalAccess`
    * `Policy.Read.All`
    * ...and **Grant Admin Consent** for them.

---
## 📁 Folder Structure

Your project is organized to separate different types of resources.

```text
my-ca-policies/
│
├── modules/
│   ├── terraform-azuread-cap/          # (For Users & Guests)
│   └── terraform-azuread-cap-workload/ # (For Workload Identities/SPNs)
│
├── backend.tf                # (Remote state config)
├── data.tf                   # (Data lookups for groups, roles, etc.)
├── locations.tf              # (All Named Locations)
├── policies.tf               # (All User & Guest CA Policies)
├── policies-workload.tf      # (All Workload Identity CA Policies)
├── provider.tf               # (Connects to Azure)
├── variables.tf              # (Your project's inputs)
├── terraform.tfvars          # (Your private values - IGNORED BY GIT)
└── README.md                 # <-- You are here!
```

---
## ⚡ How to Use

### 1. Configure the Backend

Edit the `backend.tf` file to point to the Storage Account you created.

```terraform
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "Your-Storage-RG-Name"
    storage_account_name = "youruniquestoragename"
    container_name       = "tfstate"
    key                  = "entra-id-ca.tfstate"
  }
}
```

### 2. Configure Your Variables

Create a `terraform.tfvars` file (and add it to `.gitignore`).

```hcl
# terraform.tfvars

break_glass_group_name = "grp-sec-BreakGlass-Admins"

hq_office_ips = [
  "203.0.113.1/32",
  "198.51.100.0/24"
]

blocked_countries = [
  "KP", # North Korea
  "IR"
]
```

### 3. Choose Your Authentication Method

#### Method A: Local Testing (Recommended)

Use your own credentials via the Azure CLI.

1.  Log in to your terminal: `az login`
2.  Set your tenant: `az account set --tenant "YOUR_TENANT_ID"`
3.  **Delete or comment out** the `provider "azuread"` block in `provider.tf`.
    Terraform will automatically use your `az login` credentials.

#### Method B: Pipeline / Automation (Best Practice)

Do not use the `provider.tf` block. Instead, set these environment
variables in your CI/CD pipeline:

```bash
export ARM_CLIENT_ID="your-pipeline-client-id"
export ARM_CLIENT_SECRET="your-pipeline-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

#### Method C: Insecure "Temp" Method

Edit the `provider "azuread"` block in `provider.tf` to hard-code your
secrets. **Do not do this in a real project.**

### 4. Run Terraform

1.  **Initialize:** (Run this once to set up the backend)
    ```bash
    terraform init
    ```
    *Terraform will ask to copy your state to the new backend. Type `yes`.*

2.  **Plan:**
    ```bash
    terraform plan
    ```

3.  **Apply:**
    ```bash
    terraform apply
    ```

4.  **Destroy:**
    (This will now work correctly due to the `depends_on` blocks.)
    ```bash
    terraform destroy
    ```
