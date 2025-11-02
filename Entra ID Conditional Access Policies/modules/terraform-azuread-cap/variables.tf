variable "policy_name" {
  description = "Display name for the Conditional Access policy."
  type        = string
}

variable "policy_state" {
  description = "State of the policy. Valid values are 'enabled', 'disabled', or 'enabledForReportingButNotEnforced'."
  type        = string
  default     = "enabledForReportingButNotEnforced"

  validation {
    condition     = contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], var.policy_state)
    error_message = "Valid values for policy_state are 'enabled', 'disabled', or 'enabledForReportingButNotEnforced'."
  }
}

# -----------------------------------------------------------------
# Assignments: Users and Groups
# -----------------------------------------------------------------
variable "include_users" {
  description = "List of user object IDs to include."
  type        = list(string)
  default     = null
}

variable "include_groups" {
  description = "List of group object IDs to include."
  type        = list(string)
  default     = null
}

variable "include_roles" {
  description = "List of directory role template IDs to include."
  type        = list(string)
  default     = null
}

variable "exclude_users" {
  description = "List of user object IDs to exclude. Often used for break-glass accounts."
  type        = list(string)
  default     = null
}

variable "exclude_groups" {
  description = "List of group object IDs to exclude."
  type        = list(string)
  default     = null
}

variable "exclude_roles" {
  description = "List of directory role template IDs to exclude."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------
# Assignments: Cloud Apps or Actions
# -----------------------------------------------------------------
variable "include_applications" {
  description = "List of application object IDs to include. Can use 'All' or 'None'."
  type        = list(string)
  default     = ["All"]
}

variable "exclude_applications" {
  description = "List of application object IDs to exclude."
  type        = list(string)
  default     = null
}

variable "include_user_actions" {
  description = "List of user actions to include, e.g., 'urn:user:registersecurityinfo'."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------
# Conditions
# -----------------------------------------------------------------
variable "include_locations" {
  description = "List of Named Location IDs (or 'AllTrusted') to include."
  type        = list(string)
  default     = null
}

variable "exclude_locations" {
  description = "List of Named Location IDs to exclude."
  type        = list(string)
  default     = null
}

variable "device_platforms" {
  description = "List of device platforms to target. e.g., ['android', 'ios', 'windows', 'macOS']"
  type        = list(string)
  default     = null
}

variable "client_app_types" {
  description = "List of client app types. e.g., ['browser', 'mobileAppsAndDesktopClients', 'exchangeActiveSync', 'other']"
  type        = list(string)
  default     = ["all"] # Default to "all" to prevent errors
}

variable "sign_in_risk_levels" {
  description = "List of sign-in risk levels. e.g., ['low', 'medium', 'high']"
  type        = list(string)
  default     = null
}

variable "user_risk_levels" {
  description = "List of user risk levels. e.g., ['low', 'medium', 'high']"
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------
# Access Controls: Grant
# -----------------------------------------------------------------
variable "block_access" {
  description = "Set to true to block access. This overrides all other grant controls."
  type        = bool
  default     = false
}

variable "grant_controls_operator" {
  description = "Operator for grant controls. 'OR' (require one) or 'AND' (require all)."
  type        = string
  default     = "OR"
}

variable "grant_built_in_controls" {
  description = "List of built-in controls. e.g., ['mfa', 'compliantDevice', 'domainJoinedDevice']"
  type        = list(string)
  default     = null

  # --- This validation block prevents conflicts ---
  validation {
    condition     = var.block_access == true ? var.grant_built_in_controls == null : true
    error_message = "You cannot set 'grant_built_in_controls' when 'block_access' is true."
  }
}

variable "grant_custom_controls" {
  description = "List of custom control IDs."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------
# Access Controls: Session
# -----------------------------------------------------------------
variable "session_sign_in_frequency" {
  description = "Number of hours or days before re-authentication is required."
  type        = number
  default     = null
}

variable "session_sign_in_frequency_period" {
  description = "The time period for sign_in_frequency. 'hours' or 'days'."
  type        = string
  default     = "hours"
}

variable "session_browser_persistence" {
  description = "Session persistence. 'always' or 'never'."
  type        = string
  default     = null
}

# -----------------------------------------------------------------
# Module Operation Controls
# -----------------------------------------------------------------
variable "prevent_destroy" {
  description = "If set to true, adds a lifecycle block to prevent this policy from being accidentally destroyed."
  type        = bool
  default     = false # Default to 'false' so it's safe
}