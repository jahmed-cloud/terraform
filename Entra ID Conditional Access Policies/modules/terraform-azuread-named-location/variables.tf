variable "display_name" {
  description = "The display name for the Named Location."
  type        = string
}

variable "location_type" {
  description = "The type of location. Must be 'ip' or 'country'."
  type        = string

  validation {
    condition     = contains(["ip", "country"], var.location_type)
    error_message = "Valid values for location_type are 'ip' or 'country'."
  }
}

# --- IP Location Variables ---
variable "ip_ranges" {
  description = "List of IP ranges (in CIDR format) for an 'ip' type location."
  type        = list(string)
  default     = null

  # --- THIS VALIDATION IS UPDATED ---
  validation {
    # Check if null (which is fine), OR if not null, run the regex
    condition = var.ip_ranges == null ? true : alltrue([
      for range in var.ip_ranges : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$|^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:)))(%.+)?s*(\\/(\\d|\\d\\d|1[0-1]\\d|12[0-8]))?$", range))
    ])
    error_message = "All ip_ranges must be a valid IPv4 or IPv6 CIDR string (e.g., '1.2.3.4/32')."
  }
}

variable "is_trusted" {
  description = "Set to true to mark this 'ip' type location as trusted (e.g., for MFA)."
  type        = bool
  default     = false
}

# --- Country Location Variables ---
variable "country_list" {
  description = "List of 2-letter country codes (e.g., 'US', 'GB') for a 'country' type location."
  type        = list(string)
  default     = null

  # --- THIS VALIDATION IS UPDATED ---
  validation {
    # Check if null (which is fine), OR if not null, check length
    condition     = var.country_list == null ? true : alltrue([for c in var.country_list : length(c) == 2])
    error_message = "All country codes must be 2-letter ISO codes (e.g., 'US', not 'USA')."
  }
}

variable "include_unknown_countries" {
  description = "Set to true to include unknown/anonymous IP addresses in this 'country' type location."
  type        = bool
  default     = false
}