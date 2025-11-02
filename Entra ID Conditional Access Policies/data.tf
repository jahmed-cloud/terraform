# Find your break-glass group by its name
data "azuread_group" "break_glass" {
  display_name = var.break_glass_group_name
}