# -----------------------------------------------------------------
# NEW: Create Named Location for HQ Offices (IP-based)
# -----------------------------------------------------------------
module "named_location_hq" {
  source = "./modules/terraform-azuread-named-location"

  display_name  = "NL-001: HQ Offices"
  location_type = "ip"
  ip_ranges     = var.hq_office_ips
  is_trusted    = false # Mark this location as trusted
}

# -----------------------------------------------------------------
# NEW: Create Named Location for Blocked Countries (Country-based)
# -----------------------------------------------------------------
module "named_location_blocked_countries" {
  source = "./modules/terraform-azuread-named-location"

  display_name              = "NL-002: Blocked Countries"
  location_type             = "country"
  country_list              = var.blocked_countries
  include_unknown_countries = false # Also block anonymous IPs
}
