############################
#  Provider Configuration  #
############################

variable "worker_id" {
    description = "Client Id"
    type = string
}
variable "worker_secret" {
    description = "Client Secret"
    type = string
    sensitive = true
}
variable "pingone_environment_id" {
    description = "Environment Id"
    type = string
}
variable "admin_environment_id" {
    description = "Environment Id"
    type = string
}
variable "admin_group_id" {
    description = "Group Id"
    type = string
}
variable "region" {
    description = "Region"
    type = string
    default = "NorthAmerica"
}
variable "region_code" {
    description = "Region"
    type = string
    default = "NA"
}

variable "admin_user_id" {
  type        = string
  description = "P1 Administrator to assign Roles to"
  sensitive   = true
}

variable "admin_username" {
    description = "PingOne DaVinci Admin Username"
    type = string
}

variable "admin_password" {
    description = "PingOne DaVinci Admin Password"
    type = string
}

variable "license_id" {
  type        = string
  description = "Name of the P1 license you want to assign to the Environment"
}

variable "organization_id" {
  type        = string
  description = "Your P1 Organization ID"
}

#############
#  PingOne  #
#############

variable "environment_type" {
  type        = string
  description = "Type of the PingOne Environment. Allowed values: \"SANDBOX\", \"PRODUCTION\""

  validation {
    condition     = contains(["SANDBOX", "PRODUCTION"], var.environment_type)
    error_message = "Must be either \"SANDBOX\" or \"PRODUCTION\"."
  }
}

variable "environment_name_master" {
  type        = string
  description = "Name of the PingOne Environment"
}

variable "environment_description_master" {
  type        = string
  description = "Description of the PingOne Environment"
}

variable "pingone_agreement_localization_revision_im_titanid_agreement_en_now_text" {
  type        = string
  description = "Text for agreement"
}

variable "environment_name_credentials" {
  type        = string
  description = "Name of the PingOne Environment"
}

variable "environment_description_credentials" {
  type        = string
  description = "Description of the PingOne Environment"
}

variable "environment_name_3" {
  type        = string
  description = "Name of the PingOne Environment"
}

variable "environment_description_3" {
  type        = string
  description = "Description of the PingOne Environment"
}

variable "microsoft_client_id" {
  type        = string
  description = "Microsoft Client ID"
}

variable "microsoft_client_secret" {
  type        = string
  description = "Microsoft Client Secret"
}

variable "environment_name_4" {
  type        = string
  description = "Name of the PingOne Environment"
}

variable "environment_description_4" {
  type        = string
  description = "Description of the PingOne Environment"
}