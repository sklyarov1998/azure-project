variable "vm-sku" {
  type    = string
  default = "Standard_B1ls"
}

variable "region" {
  type    = string
  default = "West Europe"
}

variable "group-name" {
  type    = string
  default = "medibot"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.group-name))
    error_message = "Group name must be a single string containing only letters and numbers with a length between 3 and 24 characters."
  }
}

# variable "db_user" {
#   type = string
#   default = "db_user"
# }

# variable "db_password" {
#   type = string
#   sensitive = true
# }

