locals {
  # Determine grant controls logic
  grant_controls_config = var.block_access ? {
    # If block_access is true, force block
    operator            = "OR"
    built_in_controls   = ["block"]
    custom_auth_factors = null
    } : (length(coalesce(var.grant_built_in_controls, [])) > 0 || length(coalesce(var.grant_custom_controls, [])) > 0 ? {
    # Otherwise, use provided grant controls
    operator            = var.grant_controls_operator
    built_in_controls   = var.grant_built_in_controls
    custom_auth_factors = var.grant_custom_controls # This was renamed
    } : null
  )

  # Session controls are invalid when blocking
  session_controls_enabled = !var.block_access && (
    var.session_sign_in_frequency != null ||
    var.session_browser_persistence != null
  )
}

# --- THIS IS THE FIX for 'lifecycle' ---
#
# Create this resource block if 'prevent_destroy' is FALSE
# We use 'count' to decide which block to create.
resource "azuread_conditional_access_policy" "cap_normal" {
  count = var.prevent_destroy ? 0 : 1 # Only create if prevent_destroy is false

  display_name = var.policy_name
  state        = var.policy_state

  # (Policy content is copied below)
  conditions {
    users {
      included_users  = var.include_users
      included_groups = var.include_groups
      included_roles  = var.include_roles
      excluded_users  = var.exclude_users
      excluded_groups = var.exclude_groups
      excluded_roles  = var.exclude_roles
    }
    applications {
      included_applications = var.include_applications
      excluded_applications = var.exclude_applications
      included_user_actions = var.include_user_actions
    }
    dynamic "devices" {
      for_each = var.device_platforms != null ? [1] : []
      content {
        filter {
          mode = "include"
          rule = "All device_platforms IN [\"${join("\", \"", var.device_platforms)}\"]"
        }
      }
    }
    client_app_types = var.client_app_types
    dynamic "locations" {
      for_each = var.include_locations != null || var.exclude_locations != null ? [1] : [] # <-- FIX 1: Was [1D]
      content {
        included_locations = var.include_locations
        excluded_locations = var.exclude_locations
      }
    }
    sign_in_risk_levels = var.sign_in_risk_levels
    user_risk_levels    = var.user_risk_levels # <-- FIX 2: Was user__risk_levels
  }
  dynamic "grant_controls" {
    for_each = local.grant_controls_config != null ? [1] : []
    content {
      operator                      = local.grant_controls_config.operator
      built_in_controls             = local.grant_controls_config.built_in_controls
      custom_authentication_factors = local.grant_controls_config.custom_auth_factors
    }
  }
  dynamic "session_controls" {
    for_each = local.session_controls_enabled ? [1] : []
    content {
      sign_in_frequency        = var.session_sign_in_frequency
      sign_in_frequency_period = var.session_sign_in_frequency_period
      persistent_browser_mode  = var.session_browser_persistence == null ? null : (var.session_browser_persistence == "always" ? "enabled" : "disabled")
    }
  }
}

# Create this resource block if 'prevent_destroy' is TRUE
# This block is identical to the one above, but adds the 'lifecycle' block.
resource "azuread_conditional_access_policy" "cap_protected" {
  count = var.prevent_destroy ? 1 : 0 # Only create if prevent_destroy is true

  # --- THIS IS THE ONLY DIFFERENCE ---
  lifecycle {
    prevent_destroy = true
  }

  display_name = var.policy_name
  state        = var.policy_state

  # (Policy content is copied from above)
  conditions {
    users {
      included_users  = var.include_users
      included_groups = var.include_groups
      included_roles  = var.include_roles
      excluded_users  = var.exclude_users
      excluded_groups = var.exclude_groups
      excluded_roles  = var.exclude_roles
    }
    applications {
      included_applications = var.include_applications
      excluded_applications = var.exclude_applications
      included_user_actions = var.include_user_actions
    }
    dynamic "devices" {
      for_each = var.device_platforms != null ? [1] : []
      content {
        filter {
          mode = "include"
          rule = "All device_platforms IN [\"${join("\", \"", var.device_platforms)}\"]"
        }
      }
    }
    client_app_types = var.client_app_types
    dynamic "locations" {
      for_each = var.include_locations != null || var.exclude_locations != null ? [1] : [] # <-- FIX 1: Was [1D]
      content {
        included_locations = var.include_locations
        excluded_locations = var.exclude_locations
      }
    }
    sign_in_risk_levels = var.sign_in_risk_levels
    user_risk_levels    = var.user_risk_levels # <-- FIX 2: Was user__risk_levels
  }
  dynamic "grant_controls" {
    for_each = local.grant_controls_config != null ? [1] : []
    content {
      operator                      = local.grant_controls_config.operator
      built_in_controls             = local.grant_controls_config.built_in_controls
      custom_authentication_factors = local.grant_controls_config.custom_auth_factors
    }
  }
  dynamic "session_controls" {
    for_each = local.session_controls_enabled ? [1] : []
    content {
      sign_in_frequency        = var.session_sign_in_frequency
      sign_in_frequency_period = var.session_sign_in_frequency_period
      persistent_browser_mode  = var.session_browser_persistence == null ? null : (var.session_browser_persistence == "always" ? "enabled" : "disabled")
    }
  }
}