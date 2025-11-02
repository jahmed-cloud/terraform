output "policy_block_legacy_auth_id" {
  description = "ID of the 'Block Legacy Auth' policy."
  value       = module.ca_block_legacy_auth.policy_id
}

output "policy_require_mfa_for_admins_id" {
  description = "ID of the 'Require MFA for Admins' policy."
  value       = module.ca_require_mfa_for_admins.policy_id
}

output "policy_require_mfa_all_users_id" {
  description = "ID of the 'Require MFA for All Users' policy."
  value       = module.ca_require_mfa_all_users.policy_id
}
# --- Outputs for new Named Locations ---

output "named_location_hq_id" {
  description = "ID of the HQ Offices Named Location."
  value       = module.named_location_hq.location_id
}

output "named_location_blocked_countries_id" {
  description = "ID of the Blocked Countries Named Location."
  value       = module.named_location_blocked_countries.location_id
}

# --- Output for the new policy ---

output "policy_block_risky_countries_id" {
  description = "ID of the 'Block Risky Countries' policy."
  value       = module.ca_block_risky_countries.policy_id
}