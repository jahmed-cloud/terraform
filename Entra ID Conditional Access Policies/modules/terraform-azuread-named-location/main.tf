resource "azuread_named_location" "location" {
  display_name = var.display_name

  # --- IP-Based Location ---
  # This block only gets created if var.location_type is "ip"
  dynamic "ip" {
    for_each = var.location_type == "ip" ? [1] : []
    content {
      ip_ranges = var.ip_ranges
      trusted   = var.is_trusted
    }
  }

  # --- Country-Based Location ---
  # This block only gets created if var.location_type is "country"
  dynamic "country" {
    for_each = var.location_type == "country" ? [1] : []
    content {
      countries_and_regions                 = var.country_list
      include_unknown_countries_and_regions = var.include_unknown_countries
    }
  }
}