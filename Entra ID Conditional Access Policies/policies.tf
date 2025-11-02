# -----------------------------------------------------------------
# POLICY 1: Block Legacy Authentication
# -----------------------------------------------------------------
module "ca_block_legacy_auth" {
  source = "./modules/terraform-azuread-cap"

  policy_name  = "CA-001: Block Legacy Authentication"
  policy_state = "enabled" # <-- This should be 'enabled' not 'report-only'

  include_users        = ["All"]
  exclude_groups       = [data.azuread_group.break_glass.object_id]
  include_applications = ["All"]
  client_app_types     = ["exchangeActiveSync", "other"]
  block_access         = true
  # prevent_destroy = true

}


# -----------------------------------------------------------------
# POLICY 2: Require MFA for Admin Roles
# -----------------------------------------------------------------
module "ca_require_mfa_for_admins" {
  source = "./modules/terraform-azuread-cap"

  policy_name  = "CA-002: Require MFA for Admin Roles"
  policy_state = "enabled" # <-- This should also be 'enabled'

  include_roles        = var.admin_roles_to_target
  include_applications = ["All"]
  grant_built_in_controls = ["mfa"]
}

# -----------------------------------------------------------------
# POLICY 3: Require MFA for All Users
# -----------------------------------------------------------------
module "ca_require_mfa_all_users" {
  source = "./modules/terraform-azuread-cap"

  policy_name  = "CA-003: Require MFA for All Users"
  policy_state = "enabledForReportingButNotEnforced"

  include_users        = ["All"]
  exclude_groups       = [data.azuread_group.break_glass.object_id]
  include_applications = ["All"]
  include_locations    = ["All"]
  exclude_locations = [
    module.named_location_hq.location_id
  ]
  grant_built_in_controls = ["mfa"]

  # --- ADD THIS DEPENDS_ON BLOCK ---
  # This tells Terraform: "Destroy this policy before you destroy
  # the 'named_location_hq' it depends on."
  depends_on = [
    module.named_location_hq
  ]
}

# -----------------------------------------------------------------
# POLICY 4: Block Access from Risky Countries
# -----------------------------------------------------------------
module "ca_block_risky_countries" {
  source = "./modules/terraform-azuread-cap"

  policy_name  = "CA-004: Block Access from Risky Countries"
  policy_state = "enabledForReportingButNotEnforced"

  include_users        = ["All"]
  exclude_groups       = [data.azuread_group.break_glass.object_id]
  include_applications = ["All"]
  
  # --- UNCOMMENT THIS LINE (if you want it active) ---
  include_locations = [
    module.named_location_blocked_countries.location_id
  ]
  block_access = true

  # --- ADD THIS DEPENDS_ON BLOCK ---
  # This tells Terraform: "Destroy this policy before you destroy
  # the 'named_location_blocked_countries' it depends on."
  depends_on = [
    module.named_location_blocked_countries
  ]
}