region                  = "NorthAmerica"
region_code             = "NA"
pingone_environment_id  = "" # Terraform Administration Environment
admin_user_id           = "" # Terraform Administration Environment
license_id              = "" # Terraform Administration Environment
worker_id               = "" # Terraform Administration Environment
worker_secret           = "" # Terraform Administration Environment
admin_username          = "" # Terraform Administration Environment
admin_password          = "" # Terraform Administration Environment
organization_id         = "" # Either Administrator or Terraform Adminstration Environment

admin_environment_id    = "" # Administrator Environment
admin_group_id          = "" # Administrator Environment


#############
#  PingOne  #
#############

environment_type = "SANDBOX"
# Change the name as needed for your P1 environment #
environment_name_master = "B2B_Master_TitanID"
environment_description_master = "Main Flow for B2B Demo"
environment_name_credentials = "B2B_Credentials"
environment_description_credentials = "Neo demo for onboarding and validating Partners. This is a standalone demo, not to be connected to the other environments.   "
# Probably want to rename these to something more descriptive - not sure what makes sense right now.
environment_name_3 = "B2B_External_Partner_SilverSurfers"
environment_description_3 = "PingOne environment for External IDP to Microsoft"
microsoft_client_id = ""
microsoft_client_secret = ""
environment_name_4 = "B2B_External_Partner_GoldenGate"
environment_description_4 = "PingOne Extnernal IDP"

