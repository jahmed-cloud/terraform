# Entra ID Conditional Access as Code (Terraform)

This project provides a complete, production-ready framework for managing Microsoft Entra ID Conditional Access (CA) policies and Named Locations using Terraform.

This framework is designed to be **scalable**, **reusable**, and **version-controlled**. Instead of clicking through the Azure portal, you define your entire security posture as code.

## 🚀 Features

* **Modular:** A clean separation between the reusable *logic* (the `modules`) and your specific *configurations* (the root `main.tf`).
* **Scalable:** Add new policies or locations by adding a single, small `module` block, not by copy-pasting hundreds of lines.
* **Dynamic:** Uses data sources to find groups and roles by their **display names**, not by hard-coding Object IDs.
* **Comprehensive:** Includes dedicated modules for:
    1.  **Conditional Access Policies:** The core policy engine.
    2.  **Named Locations:** Create and manage both IP-based (like "HQ Office") and Country-based (like "Blocked Countries") locations.

---

## 📋 Prerequisites

Before you can use this code, you must have the following:

1.  **Terraform:** Version 1.0 or newer installed.
2.  **Authentication Credentials:** You will need a **Service Principal** (an application identity) with the following details:
    * `tenant_id`
    * `client_id`
    * `client_secret`
3.  **Permissions:** Your Service Principal **must** be assigned one of the following Entra ID roles. The least-privileged role is recommended.
    * **Conditional Access Administrator** (Least-privileged)
    * **Security Administrator**
    * **Global Administrator**

---

## 📁 Folder Structure

Your project is organized into two main parts: the `modules` (the building blocks) and the *root configuration* (your implementation).

```text
my-ca-policies/
│
├── modules/
│   │
│   ├── terraform-azuread-cap/          # Module for CA Policies
│   │   ├── main.tf                     # (Policy logic)
│   │   ├── variables.tf                # (Policy inputs)
│   │   └── outputs.tf                  # (Policy outputs)
│   │
│   └── terraform-azuread-named-location/ # Module for Named Locations
│       ├── main.tf                     # (Location logic)
│       ├── variables.tf                # (Location inputs)
│       └── outputs.tf                  # (Location outputs)
│
├── provider.tf             # <-- You will edit this for auth
├── policies.tf             # (Holds all your CA policies)
├── locations.tf            # (Holds all your Named Locations)
├── variables.tf            # (Your project's inputs)
├── data.tf                 # (Finds existing Entra ID groups/roles)
├── outputs.tf              # (Your project's outputs)
├── terraform.tfvars.example  # (Example variables file)
└── README.md               # <-- You are here!
```

---

## ⚡ How to Use This Code (Step-by-Step)

### Step 1: Configure Authentication (Hard-Coded)

Open the `provider.tf` file. Fill in your Service Principal's credentials directly.

> 🚨 **WARNING: DO NOT** commit this file to a shared repository (like Git) with these secrets in it. This method is **not secure** and is only for quick, temporary, local testing.

**`provider.tf`:**
```terraform
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azuread" {
  # --- Enter your credentials below ---
  
  tenant_id     = "YOUR_TENANT_ID_GOES_HERE"
  client_id     = "YOUR_CLIENT_ID_GOES_HERE"
  client_secret = "YOUR_CLIENT_SECRET_GOES_HERE"
}
```

### Step 2: Configure Your Variables

1.  Create a new file in this main folder named `terraform.tfvars`.
2.  Copy the content from `terraform.tfvars.example` and fill in your values.

**Example `terraform.tfvars` file:**

```hcl
# The exact display name of your emergency access group
break_glass_group_name = "grp-sec-BreakGlass-Admins"

# Your trusted corporate office IP ranges
hq_office_ips = [
  "203.0.113.1/32",
  "198.51.100.0/24"
]

# Countries you want to block
blocked_countries = [
  "KP", # North Korea
  "IR",  # Iran
]
```

### Step 3: Run Terraform

In your terminal, from the root `my-ca-policies/` directory, run the following commands:

1.  **Initialize the project:**
    (This downloads the `azuread` provider and registers your local modules.)
    ```bash
    terraform init
    ```

2.  **Plan your changes:**
    (This shows you what Terraform *will* create or change, without doing it.)
    ```bash
    terraform plan
    ```

3.  **Apply your configuration:**
    (This creates the policies and locations in Entra ID. You will have to type `yes` to approve.)
    ```bash
    terraform apply
    ```

---

## 🧑‍💻 How to Add New Policies and Locations

This is the most common task you will do. You **do not** need to edit the `modules` folders. You only edit your `policies.tf` or `locations.tf` files.

### How to Add a New Conditional Access Policy

1.  Open the root `policies.tf` file.
2.  Go to the bottom and paste in a new `module` block.
3.  Give it a unique name (e.g., `ca_block_high_risk_users`) and set the `policy_name`.
4.  Configure the inputs (like `include_groups`, `sign_in_risk_levels`, etc.) from the module's `variables.tf`.

**Example: Add a new policy to block high-risk users**

```terraform
# --- Add this block to your policies.tf ---

module "ca_block_high_risk_users" {
  source = "./modules/terraform-azuread-cap"

  policy_name  = "CA-005: Block High-Risk Users"
  policy_state = "enabled"

  # ---Assignments---
  include_users = ["All"]
  exclude_groups = [data.azuread_group.break_glass.object_id]

  # ---Conditions---
  # This targets any user flagged as "High" risk by Entra ID Protection
  user_risk_levels = ["high"]

  # ---Controls---
  block_access = true
}
```

### How to Add a New Named Location

1.  Open the root `locations.tf` file.
2.  Paste in the `module "terraform-azuread-named-location"` block.
3.  Give it a unique name (e.g., `named_location_branch_offices`) and set the inputs.
4.  (Optional) You can immediately use the output (`module.named_location_branch_offices.location_id`) in another policy.

**Example: Add a "Branch Offices" location**

```terraform
# --- Add this block to your locations.tf ---

module "named_location_branch_offices" {
  source = "./modules/terraform-azuread-named-location"

  display_name  = "NL-003: Branch Offices"
  location_type = "ip"
  ip_ranges     = ["192.0.2.0/24"] # You can get this from a var
  is_trusted    = true
}
```
