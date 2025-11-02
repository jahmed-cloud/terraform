# -----------------------------------------------------------------
# terraform.tfvars
#
# This file contains your specific, private values.
# DO NOT commit this file to Git.
# -----------------------------------------------------------------

# --- Security Groups ---

# (Required) The EXACT display name of your emergency access group.
# This group is excluded from policies to prevent locking yourself out.
break_glass_group_name = "BreakGlass-Accounts-sg"


# --- IP-Based Named Locations ---

# (Optional) IP ranges for your main HQ office.
# These will be marked as "trusted" and can be used to bypass MFA.
hq_office_ips = [
  "192.0.2.1/32",
  "203.0.113.0/24"
]

# (Optional) IP ranges for your data center.
# These will also be marked as "trusted".
data_center_ips = [
  "198.51.100.5/32"
]


# --- Country-Based Named Locations ---

# (Optional) A list of 2-letter country codes to block.
# These will be used in a policy to block access.
blocked_countries = [
  "KP", # North Korea
  "IR", # Iran
  "SY"  # Syria
]