variable "environment" {
  description = "Environment/branch used"
  type        = string
}
variable "website_path" {
  default = "site/"
}

variable "R53DomainName" {
  default = "johminsoo.com"
}

variable "R53ZoneID" {
  default = "Z020260338X95XEAE0D6V"
}