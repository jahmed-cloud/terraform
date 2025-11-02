output "policy_id" {
  description = "The Object ID of the Conditional Access policy."
  
  # --- THIS IS THE FIX ---
  # 'concat' merges the two lists (one will be empty, one will have 1 item).
  # 'one()' extracts that single item from the merged list.
  value = one(concat(
    azuread_conditional_access_policy.cap_normal[*].id,
    azuread_conditional_access_policy.cap_protected[*].id
  ))
}

output "policy_display_name" {
  description = "The display name of the Conditional Access policy."

  # --- THIS IS THE FIX ---
  value = one(concat(
    azuread_conditional_access_policy.cap_normal[*].display_name,
    azuread_conditional_access_policy.cap_protected[*].display_name
  ))
}