variable "break_glass_group_name" {
  description = "The display name of your emergency 'break-glass' admin group."
  type        = string
}

variable "admin_roles_to_target" {
  description = "A list of Role Template IDs for admins to target for MFA."
  type        = list(string)
  default = [
    "62e90394-69f5-4237-9190-012177145e10", # Global Administrator
    "e8611ab8-c189-46e8-94e1-60213ab1f814", # Security Administrator
    "b0f54661-2d74-4c50-afa3-1ec803f12efe"  # Exchange Administrator
  ]
}
# --- New variables for Named Locations ---

variable "hq_office_ips" {
  description = "A list of CIDR IP ranges for the corporate HQ."
  type        = list(string)
  default     = []
}

variable "blocked_countries" {
  description = "A list of 2-letter country codes to block."
  type        = list(string)
  default     = []
}

variable "data_center_ips" {
  description = "A list of trusted IP ranges for the new data center."
  type        = list(string)
  default     = []
}