variable "region" {
  description = "Region"
}

variable "record_name" {
  description = "The DNS record name"
}

variable "dest_zone_id" {
  description = "The destination zone ID for the record to point to"
}

variable "dest_record_name" {
  description = "The destination DNS record name"
}