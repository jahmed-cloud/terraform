output "location_id" {
  description = "The Object ID of the created Named Location."
  value       = azuread_named_location.location.id
}

output "location_display_name" {
  description = "The display name of the created Named Location."
  value       = azuread_named_location.location.display_name
}