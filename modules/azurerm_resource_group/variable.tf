variable "rgs" {
  type = map(object({
  name       = string
  location   = string
  managed_by = optional(string)
  tags       = map(string)
    }))
}

variable "default_tags" {
  type    = map(string)
  default = {}
}