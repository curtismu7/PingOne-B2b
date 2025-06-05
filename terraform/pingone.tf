##################
#  Data Sources  #
##################

data "pingone_licenses" "internal_license" {
  organization_id = var.organization_id
  # If the license ID is empty, grab the license ID from the TF environment. If the license ID is present, we don't really care, we'll use var.license_id elsewhere. 
  scim_filter     = var.license_id != "" ? "(status eq \"active\")" : "(status eq \"active\") and (envId eq \"${var.pingone_environment_id}\")"
}

data "pingone_role" "environment_admin" {
  name = "Environment Admin"
}

data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}

data "pingone_role" "client_application_developer" {
  name = "Client Application Developer"
}

data "pingone_role" "davinci_admin" {
  name = "DaVinci Admin"
}

###########
#  Roles  #
###########

variable "environment_ids" {
  type = set(string)
  default = ["env1", "env2", "env3", "env4"]
}

locals  {
  environment_ids = {
    "env1" = pingone_environment.internal_master_environment.id, 
    "env2" = pingone_environment.credentials_environment.id,
    "env3" = pingone_environment.environment_3.id,
    "env4" = pingone_environment.environment_4.id
    }
}

resource "pingone_user_role_assignment" "id_admin" {
  for_each = var.environment_ids

  environment_id = var.pingone_environment_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_user_role_assignment" "app_dev" {
  for_each = var.environment_ids

  environment_id = var.pingone_environment_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.client_application_developer.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_user_role_assignment" "env_admin" {
  for_each = var.environment_ids

  environment_id = var.pingone_environment_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_user_role_assignment" "davinci_admin" {
  for_each = var.environment_ids

  environment_id = var.pingone_environment_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.davinci_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_group_role_assignment" "id_admin" {
  for_each = var.environment_ids

  environment_id = var.admin_environment_id
  group_id        = var.admin_group_id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_group_role_assignment" "app_dev" {
  for_each = var.environment_ids

  environment_id = var.admin_environment_id
  group_id        = var.admin_group_id
  role_id        = data.pingone_role.client_application_developer.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_group_role_assignment" "env_admin" {
  for_each = var.environment_ids

  environment_id = var.admin_environment_id
  group_id        = var.admin_group_id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

resource "pingone_group_role_assignment" "davinci_admin" {
  for_each = var.environment_ids

  environment_id = var.admin_environment_id
  group_id        = var.admin_group_id
  role_id        = data.pingone_role.davinci_admin.id

  scope_environment_id = local.environment_ids["${each.value}"]
}

################################
#  Interal Master Environment  #
################################

resource "pingone_environment" "internal_master_environment" {         
  name        = var.environment_name_master
  type        = var.environment_type
  license_id  = var.license_id != "" ? var.license_id : data.pingone_licenses.internal_license.ids[0]

  services = [
    {
      type = "SSO"
    },
    {
      type = "MFA"
    },
    {
      type = "DaVinci",
      tags  = ["DAVINCI_MINIMAL"]
    },
      {
      type = "Verify"
    },    
    {
      type = "Risk"
    },
    {
      type = "Credentials"
    }
  ]
}

# resource "pingone_mfa_settings" "mfa_settings_off" {
#   environment_id = pingone_environment.internal_master_environment.id

#   pairing = {
#     max_allowed_devices = 5
#     pairing_key_format  = "ALPHANUMERIC"
#   }

#   lockout = {
#     failure_count    = 5
#     duration_seconds = 600
#   }

#   phone_extensions = {
#     enabled = true
#   }

#   users = {
#     mfa_enabled = false
#   }

#   lifecycle {
# 	  ignore_changes = all
# 	}
# }

resource "pingone_mfa_settings" "mfa_settings_on" {
  environment_id = pingone_environment.internal_master_environment.id

  pairing = {
    max_allowed_devices = 5
    pairing_key_format  = "ALPHANUMERIC"
  }

  lockout = {
    failure_count    = 5
    duration_seconds = 600
  }

  phone_extensions = {
    enabled = true
  }

  users = {
    mfa_enabled = true
  }

  #depends_on = [ pingone_mfa_settings.mfa_settings_off ]
}

########################################
#  Interal Master Environment - Users  #
########################################

variable "user_index" {
  type = set(string)
  default = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

resource "random_integer" "im_titan_id_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_titan_id_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_titanid_population.id

  email    = "admin.${random_integer.im_titan_id_admin_number.result}@titanid.com"
  username = "admin@titanid.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "TitanID"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_titan_id_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_titan_id_admin_user.id
  group_id = pingone_group.titan_id_group.id
}

resource "random_string" "im_titan_id_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_titan_id_user" {
  for_each = var.user_index

  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_titanid_population.id

  email    = "b2bpingdemo+user-${random_string.im_titan_id_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@titanid.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "TitanID"
    family           = "User ${each.value}"
  }
  mfa_enabled = true
}

# See this example for how to assign users generated from a for_each to a group
# resource "pingone_user_group_assignment" "im_titan_id_user_group" {
#   for_each = var.user_index
#   environment_id = pingone_environment.internal_master_environment.id

#   user_id  = pingone_user.im_titan_id_user["${each.key}"].id
#   group_id = pingone_group.titan_id_group.id
# }

resource "random_integer" "im_crimson_trust_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_crimson_trust_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_crimson_trust_population.id

  email    = "admin.${random_integer.im_titan_id_admin_number.result}@crimsontrust.com"
  username = "admin@crimsontrust.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "CrimsonTrust"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_crimson_trust_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_crimson_trust_admin_user.id
  group_id = pingone_group.crimson_trust_group.id
}

resource "random_string" "im_crimson_trust_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_crimson_trust_user" {
  for_each = var.user_index

  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_crimson_trust_population.id

  email    = "b2bpingdemo+user-${random_string.im_crimson_trust_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@crimsontrust.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "CrimsonTrust"
    family           = "User ${each.value}"
  }
  mfa_enabled = true
}


resource "random_integer" "im_silver_surfers_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_silver_surfers_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_environment_3_population.id

  email    = "admin.${random_integer.im_silver_surfers_admin_number.result}@silversurfers.com"
  username = "admin@silversurfers.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "SilverSurfers"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_silver_surfers_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_silver_surfers_admin_user.id
  group_id = pingone_group.silver_surfers_group.id
}

resource "random_string" "im_silver_surfers_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_silver_surfers_user" {
  for_each = var.user_index

  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_environment_3_population.id

  email    = "b2bpingdemo+user-${random_string.im_silver_surfers_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@silversurfers.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "SilverSurfers"
    family           = "User ${each.value}"
  }
  mfa_enabled = true
}

resource "random_integer" "im_verde_persona_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_verde_persona_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_verde_persona_population.id

  email    = "admin.${random_integer.im_verde_persona_admin_number.result}@verdepersona.com"
  username = "admin@verdepersona.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "VerdePersona"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_verde_persona_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_verde_persona_admin_user.id
  group_id = pingone_group.verde_persona_group.id
}

resource "random_string" "im_verde_persona_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_verde_persona_user" {
  for_each = var.user_index

  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_verde_persona_population.id

  email    = "b2bpingdemo+user-${random_string.im_verde_persona_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@verdepersona.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "VerdePersona"
    family           = "User ${each.value}"
  }
  mfa_enabled = true
}

resource "random_integer" "im_blue_shield_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_blue_shield_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_blueshield_population.id

  email    = "admin.${random_integer.im_blue_shield_admin_number.result}@blueshield.com"
  username = "admin@blueshield.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "BlueShield"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_blue_shield_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_blue_shield_admin_user.id
  group_id = pingone_group.blue_shield_group.id
}

resource "random_string" "im_blue_shield_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_blue_shield_user" {
  for_each = var.user_index

  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_blueshield_population.id

  email    = "b2bpingdemo+user-${random_string.im_blue_shield_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@blueshield.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "BlueShield"
    family           = "User ${each.value}"
  }
  mfa_enabled = true
}

resource "random_integer" "im_golden_gate_admin_number" {
  min = 1
  max = 999
}

resource "pingone_user" "im_golden_gate_admin_user" {
  environment_id = pingone_environment.internal_master_environment.id

  population_id = pingone_population.im_environment_4_population.id

  email    = "admin.${random_integer.im_golden_gate_admin_number.result}@goldengate.com"
  username = "admin@goldengate.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "Admin"
    family           = "GoldenGate"
  }
  mfa_enabled = true
}

resource "pingone_user_group_assignment" "im_golden_gate_admin_group" {
  environment_id = pingone_environment.internal_master_environment.id

  user_id  = pingone_user.im_golden_gate_admin_user.id
  group_id = pingone_group.golden_gate_group.id
}

###############################################
#  Interal Master Environment - Custom Roles  #
###############################################

resource "pingone_custom_role" "ext_idp_custom" {
  environment_id = pingone_environment.internal_master_environment.id

  name = "ManageExtIDP"
  description = "My custom role for External IdP Access"

  applicable_to = [
    "POPULATION",
    "ENVIRONMENT"
  ]

  can_be_assigned_by = [
    {
      id = data.pingone_role.environment_admin.id
    }
  ]

  permissions = [
    {
      id = "identityProviders:create:identityProvider"
    },
    {
      id = "identityProviders:delete:identityProvider"
    },
    {
      id = "identityProviders:read:identityProvider"
    },
    {
      id = "identityProviders:update:identityProvider"
    },
    {
      id = "licensing:read:license"
    },
    {
      id = "orgmgt:read:deployment"
    },
    {
      id = "orgmgt:read:environment"
    },
    {
      id = "orgmgt:read:organization"
    }
  ]
} 

resource "pingone_custom_role" "partner_app_access_role" {
  environment_id = pingone_environment.internal_master_environment.id

  name        = "PartnerAppAccess"
  description = "My custom role for Partner App Access"

  applicable_to = [
    "ENVIRONMENT"
  ]

  can_be_assigned_by = [
    {
      id = data.pingone_role.environment_admin.id
    }
  ]

permissions = [
  { id = "applications:create:application" },
  { id = "applications:create:grant" },
  { id = "applications:delete:application" },
  { id = "applications:delete:grant" },
  { id = "applications:read:application" },
  { id = "applications:read:flowPolicyAssignment" },
  { id = "applications:read:grant" },
  { id = "applications:update:application" },
  { id = "applications:update:flowPolicyAssignment" },
  { id = "applications:update:grant" },
  { id = "authn:create:signOnPolicy" },
  { id = "authn:delete:signOnPolicy" },
  { id = "authn:read:signOnPolicy" },
  { id = "authn:update:signOnPolicy" },
  { id = "branding:create:customDomain" },
  { id = "branding:delete:customDomain" },
  { id = "branding:read:customDomain" },
  { id = "branding:update:customDomain" },
  { id = "certmgt:create:certificate" },
  { id = "certmgt:create:key" },
  { id = "certmgt:delete:certificate" },
  { id = "certmgt:delete:key" },
  { id = "certmgt:read:certificate" },
  { id = "certmgt:read:key" },
  { id = "certmgt:update:certificate" },
  { id = "certmgt:update:key" },
  { id = "console:display:environmentOverview" },
  { id = "console:display:environmentProperties" },
  { id = "devices:create:seenDevice" },
  { id = "devices:delete:seenDevice" },
  { id = "devices:read:seenDevice" },
  { id = "devices:update:seenDevice" },
  { id = "dir:forceChange:userPassword" },
  { id = "dir:read:schema" },
  { id = "dir:read:userPassword" },
  { id = "dir:recover:userPassword" },
  { id = "dir:reset:userPassword" },
  { id = "dir:set:userPassword" },
  { id = "dir:unlock:userPassword" },
  { id = "dir:validate:userPassword" },
  { id = "flowPolicies:read:flowPolicy" },
  { id = "globalregistry:read:console" },
  { id = "integrations:read:integration" },
  { id = "licensing:read:license" },
  { id = "licensing:update:environmentLicense" },
  { id = "orgmgt:read:deployment" },
  { id = "orgmgt:read:environment" },
  { id = "orgmgt:read:organization" },
  { id = "permissions:read:applicationRoleAssignments" },
  { id = "resources:create:attribute" },
  { id = "resources:create:scope" },
  { id = "resources:delete:attribute" },
  { id = "resources:delete:scope" },
  { id = "resources:read:attribute" },
  { id = "resources:read:resource" },
  { id = "resources:read:scope" },
  { id = "resources:update:attribute" },
  { id = "resources:update:scope" },
  { id = "visualization:read:dashboard" },
  { id = "visualization:read:userDemographics" }
]
}

resource "pingone_custom_role" "user_population_access" {
  environment_id = pingone_environment.internal_master_environment.id

  name        = "userPopulationAccess"
  description = "My custom role for User Population Access"

  applicable_to = [
    "POPULATION",
    "ENVIRONMENT"
  ]

  can_be_assigned_by = [
    {
      id = data.pingone_role.environment_admin.id
    }
  ]

permissions = [
  { id = "dir:create:group" },
  { id = "dir:create:groupMembership" },
  { id = "dir:create:population" },
  { id = "dir:create:user" },
  { id = "dir:delete:group" },
  { id = "dir:delete:groupMembership" },
  { id = "dir:delete:population" },
  { id = "dir:delete:user" },
  { id = "dir:import:user" },
  { id = "dir:invite:user" },
  { id = "dir:provision:group" },
  { id = "dir:read:group" },
  { id = "dir:read:groupMembership" },
  { id = "dir:read:population" },
  { id = "dir:read:user" },
  { id = "dir:update:group" },
  { id = "dir:update:population" },
  { id = "dir:update:user" },
  { id = "dir:verify:user" },
  { id = "orgmgt:read:deployment" },
  { id = "orgmgt:read:environment" },
  { id = "permissions:create:groupRoleAssignments" },
  { id = "permissions:delete:groupRoleAssignments" },
  { id = "permissions:read:groupRoleAssignments" }
]
}

##############################################
#  Internal Master Environment - Populations  #
##############################################

resource "pingone_population" "im_titanid_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "TitanID"
  alternative_identifiers = ["titanid.com", "titanidsolutions.com"]
  theme = {
   id = pingone_branding_theme.im_titanid_theme.id
  }
}

resource "pingone_population" "im_crimson_trust_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "CrimsonTrust"
  alternative_identifiers = ["crimsontrust.com", "crimsontrust", "crimsontrust__ALL"]
  theme       = {
    id        = pingone_branding_theme.im_crimson_trust_theme.id
  }
}

resource "pingone_population" "im_environment_4_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "GoldenGate"
  alternative_identifiers = ["goldengate.com", "goldengate", "goldengate__ALL"]
  theme = {
    id = pingone_branding_theme.im_environment_4_theme.id
  }
}

resource "pingone_population_default_identity_provider" "im_environment_4_population_IdP" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id  = pingone_population.im_environment_4_population.id

  identity_provider_id = pingone_identity_provider.im_environment_4_identity_provider.id
}

resource "pingone_population" "im_blueshield_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "BlueShield"
  alternative_identifiers = ["blueshield.com", "blueshield", "blueshield__FIDO2", "blueshield__MOBILE", "blueshield__TOTP", "blueshield__SMS", "blueshield__EMAIL", "blueshieldsystems.com"]
  theme = {
    id = pingone_branding_theme.im_blueshield_systems_theme.id
  }
}

resource "pingone_population" "im_environment_3_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "SilverSurfers"
  alternative_identifiers = ["silversurfers.com", "silversurfers"]
  theme = {
    id = pingone_branding_theme.im_environment_3_theme.id
  }
}

resource "pingone_population_default_identity_provider" "im_environment_3_population_IdP" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id  = pingone_population.im_environment_3_population.id

  identity_provider_id = pingone_identity_provider.im_environment_3_identity_provider.id
}

resource "pingone_population" "im_verde_persona_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "VerdePersona"
  alternative_identifiers = ["verdepersona.com", "verdepersona", "verdepersona__EMAIL"]
  theme = {
    id = pingone_branding_theme.im_verde_persona_theme.id
  }
  preferred_language = "es"
}

resource "pingone_population" "im_employee_creds_population" {
  environment_id = pingone_environment.internal_master_environment.id
  
  name        = "Employee_Creds"
}

#########################################
#  Interal Master Environment - Groups  #
#########################################

resource "pingone_group" "crimson_trust_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_crimson_trust_population.id

  name        = "CrimsonTrustAdmins"
  description = "Group for CrimsonTrust"

  custom_data = jsonencode({
    "Users" = "Non-Admin"
  })

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "crimson_trust_group_role" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.crimson_trust_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_population_id = pingone_population.im_crimson_trust_population.id
}

resource "pingone_group" "golden_gate_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_environment_4_population.id

  name        = "GoldenGateAdmins"
  description = "Group for GoldenGate"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "golden_gate_group_role_ext_idp" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.golden_gate_group.id
  role_id        = pingone_custom_role.ext_idp_custom.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_group_role_assignment" "golden_gate_group_role_pop_access" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.golden_gate_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_group" "blue_shield_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_blueshield_population.id

  name        = "BlueShieldAdmins"
  description = "Group for BlueShield"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "blue_shield_group_role" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.blue_shield_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_population_id = pingone_population.im_blueshield_population.id
}

# resource "pingone_group" "silver_surfers_users_group" {
#   environment_id = pingone_environment.internal_master_environment.id
#   population_id = pingone_population.im_environment_3_population.id

#   name        = "SilverSurfersUsers"
#   description = "Group for SilverSurfers"

#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "pingone_group" "silver_surfers_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_environment_3_population.id

  name        = "SilverSurfersAdmins"
  description = "Group for SilverSurfers Admins"

  lifecycle {
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "silver_surfers_group_role" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.silver_surfers_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_population_id = pingone_population.im_environment_3_population.id
}

# resource "pingone_group" "verde_persona_users_group" {
#   environment_id = pingone_environment.internal_master_environment.id
#   population_id = pingone_population.im_verde_persona_population.id

#   name        = "VerdePersonaUsers"
#   description = "Group for VerdePersona"

#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "pingone_group" "verde_persona_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_verde_persona_population.id

  name        = "VerdePersonaAdmins"
  description = "Group for VerdePersona Admins"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "verde_persona_group_role" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.verde_persona_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_population_id = pingone_population.im_verde_persona_population.id
}

# resource "pingone_group" "titan_id_users_group" {
#   environment_id = pingone_environment.internal_master_environment.id
#   population_id = pingone_population.im_titanid_population.id

#   name        = "TitanIDUsers"
#   description = "Group for TitanID Users"

#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "pingone_group" "titan_id_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_titanid_population.id

  name        = "TitanIDAdmins"
  description = "Group for TitanID Admins"

  lifecycle {
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "titan_id_group_role" {
  environment_id = pingone_environment.internal_master_environment.id
  group_id       = pingone_group.titan_id_group.id
  role_id        = pingone_custom_role.user_population_access.id

  scope_population_id = pingone_population.im_titanid_population.id
}

resource "pingone_group" "crimson_trust_users_group" {
  environment_id = pingone_environment.internal_master_environment.id
  population_id = pingone_population.im_crimson_trust_population.id

  name        = "CrimsonTrustUsers"
  description = "Group for CrimsonTrust Users"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group" "titan_app_group" {
  environment_id = pingone_environment.internal_master_environment.id

  name        = "TitanIDAppAccess"
  description = "Group for TitanID Users"

  user_filter = "population.id eq \"${pingone_population.im_titanid_population.id}\""

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

###############################################
#  Interal Master Environment - Applications  #
###############################################

resource "pingone_key" "im_signing_key" {
  environment_id = pingone_environment.internal_master_environment.id

  name                = "${var.environment_name_master} Signing Key"
  algorithm           = "RSA"
  key_length          = 4096
  signature_algorithm = "SHA512withRSA"
  subject_dn          = "CN={var.environment_name_master} Signing Key, OU=Sales Engineering, L=, ST=, C=US"
  usage_type          = "SIGNING"
  validity_period     = 365
}

resource "pingone_system_application" "im_pingone_portal" {
  environment_id = pingone_environment.internal_master_environment.id

  type    = "PING_ONE_PORTAL"
  enabled = true
}

resource "pingone_application_flow_policy_assignment" "im_pingone_portal" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_system_application.im_pingone_portal.id

  flow_policy_id = davinci_application_flow_policy.B2B-Alternate.id

  priority = 1
}

resource "pingone_system_application" "im_pingone_self_service" {
  environment_id = pingone_environment.internal_master_environment.id

  type    = "PING_ONE_SELF_SERVICE"
  enabled = true

  apply_default_theme         = true
  enable_default_theme_footer = true
}

resource "pingone_application_flow_policy_assignment" "im_pingone_self_service" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_system_application.im_pingone_self_service.id

  flow_policy_id = davinci_application_flow_policy.B2B-Alternate.id

  priority = 1
}

resource "pingone_application" "im_idfirst_app" {
  environment_id = pingone_environment.internal_master_environment.id
  name           = "IDFirst"
  enabled        = true

  saml_options = {
    acs_urls           = ["https://decoder.pingidentity.cloud/saml"]
    assertion_duration = 3600
    sp_entity_id       = "https://decoder.pingidentity.cloud/saml"

    idp_signing_key = {
      key_id    = pingone_key.im_signing_key.id
      algorithm = pingone_key.im_signing_key.signature_algorithm
    }
  }

  icon = {
    id   = pingone_image.im_idfirst_logo.id
    href = pingone_image.im_idfirst_logo.uploaded_image.href
  }
}

resource "pingone_application_sign_on_policy_assignment" "im_idfirst_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_idfirst_app.id

  sign_on_policy_id = pingone_sign_on_policy.im_id_first_authentication_policy.id

  priority = 1
}

resource "pingone_application" "im_titanid_app" {
  environment_id = pingone_environment.internal_master_environment.id
  name           = "TitanID-SAMLDecoder"
  enabled        = true

  saml_options = {
    acs_urls           = ["https://decoder.pingidentity.cloud/saml"]
    assertion_duration = 3600
    sp_entity_id       = "SAML:Decoder"

    idp_signing_key = {
      key_id    = pingone_key.im_signing_key.id
      algorithm = pingone_key.im_signing_key.signature_algorithm
    }
  }
  icon = {
    id   = pingone_image.im_titanid_app_logo.id
    href = pingone_image.im_titanid_app_logo.uploaded_image.href
  }
}

resource "pingone_application_flow_policy_assignment" "im_titanid_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_titanid_app.id

  flow_policy_id = davinci_application_flow_policy.B2B-Alternate.id

  priority = 1
}

resource "pingone_application" "im_verde_persona_app" {
  environment_id = pingone_environment.internal_master_environment.id
  name           = "VerdePersona Shipping"
  enabled        = true

  saml_options = {
    acs_urls           = ["https://decoder.pingidentity.cloud/saml"]
    assertion_duration = 3600
    sp_entity_id       = "vp:SAML"

    idp_signing_key = {
      key_id    = pingone_key.im_signing_key.id
      algorithm = pingone_key.im_signing_key.signature_algorithm
    }
  }

  icon = {
    id   = pingone_image.im_verde_persona_app_logo.id
    href = pingone_image.im_verde_persona_app_logo.uploaded_image.href
  }
}

resource "pingone_application_flow_policy_assignment" "im_verde_persona_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_verde_persona_app.id

  flow_policy_id = davinci_application_flow_policy.Dummy-App.id

  priority = 1
}

resource "pingone_application" "im_blueshield_app" {
  environment_id = pingone_environment.internal_master_environment.id
  enabled        = true
  name           = "blueshield Systems"

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method = "NONE"
  }

  icon = {
    id   = pingone_image.im_blueshield_systems_logo.id
    href = pingone_image.im_blueshield_systems_logo.uploaded_image.href
  }
}

resource "pingone_application_flow_policy_assignment" "im_blueshield_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_blueshield_app.id

  flow_policy_id = davinci_application_flow_policy.PingOne-SSO-Flow-Policy.id

  priority = 1
}

resource "pingone_application" "im_oidc_sample_app" {
  environment_id = pingone_environment.internal_master_environment.id
  enabled        = true
  name           = "OIDCSample"

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method = "NONE"
    redirect_uris               = ["https://decoder.pingidentity.cloud/oidc", "https://apps.pingone.com/${pingone_environment.internal_master_environment.id}/myaccount/"]
  }
}

resource "pingone_application_flow_policy_assignment" "im_oidc_sample_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_oidc_sample_app.id

  flow_policy_id = davinci_application_flow_policy.B2B-Alternate.id

  priority = 1
}

resource "pingone_application" "im_partner_oidc_extidp_app" {
  environment_id = pingone_environment.internal_master_environment.id
  enabled        = true
  name           = "Partner OIDC ExtIDP"

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method = "NONE"
    redirect_uris               = ["https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/rp/callback/openid_connect"]
  }
}

resource "pingone_application_secret" "im_partner_oidc_extidp_secret" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_partner_oidc_extidp_app.id
}

resource "pingone_application_flow_policy_assignment" "partner_oidc_extidp_app" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_partner_oidc_extidp_app.id

  flow_policy_id = davinci_application_flow_policy.B2B-Alternate.id

  priority = 1
}

resource "pingone_application" "im_dv_worker_app" {
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne DaVinci Connection"
  enabled        = true

  oidc_options = {
    type                        = "WORKER"
    grant_types                 = ["CLIENT_CREDENTIALS"]
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
  }

  icon = {
    id   = "c6dbb456-0857-4fab-bfb0-909944233017"
    href = "https://assets.pingone.com/ux/ui-library/4.18.0/images/logo-pingidentity.png"
  }
}

resource "pingone_application_secret" "im_dv_worker_secret" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_dv_worker_app.id
}


resource "pingone_application" "im_theme_worker_app" {
  environment_id = pingone_environment.internal_master_environment.id
  name           = "ThemeWorker"
  enabled        = true

  oidc_options = {
    type                        = "WORKER"
    grant_types                 = ["CLIENT_CREDENTIALS"]
    token_endpoint_auth_method = "CLIENT_SECRET_POST"
  }

  # icon = {
  #   id   = "c6dbb456-0857-4fab-bfb0-909944233017"
  #   href = "https://assets.pingone.com/ux/ui-library/4.18.0/images/logo-pingidentity.png"
  # }
}

resource "pingone_application_secret" "im_theme_worker_secret" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_theme_worker_app.id
}

#####################################################
#  Interal Master Environment - Applications Roles  #
#####################################################

resource "pingone_application_role_assignment" "im_dv_id_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_dv_worker_app.id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_dv_env_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_dv_worker_app.id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_dv_dv_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_dv_worker_app.id
  role_id        = data.pingone_role.davinci_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_theme_id_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_theme_worker_app.id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_theme_env_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_theme_worker_app.id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_theme_dv_admin" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_theme_worker_app.id
  role_id        = data.pingone_role.davinci_admin.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

resource "pingone_application_role_assignment" "im_theme_client_app_developer" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = pingone_application.im_theme_worker_app.id
  role_id        = data.pingone_role.client_application_developer.id

  scope_environment_id = pingone_environment.internal_master_environment.id
}

##############################################################
#  Interal Master Environment - External Identity Providers  #
##############################################################

resource "pingone_identity_provider" "im_environment_3_identity_provider" {
  environment_id = pingone_environment.internal_master_environment.id
  registration_population_id = pingone_population.im_environment_3_population.id
  name    = var.environment_name_3
  enabled = true

  openid_connect = {
    client_id = pingone_application.environment_3_titan_solutions.oidc_options.client_id
    client_secret = pingone_application_secret.environment_3_titan_solutions_secret.secret
    authorization_endpoint = "https://auth.pingone.com/${pingone_environment.environment_3.id}/as/authorize"
    issuer = "https://auth.pingone.com/${pingone_environment.environment_3.id}/as"
    jwks_endpoint = "https://auth.pingone.com/${pingone_environment.environment_3.id}/as/jwks"
    scopes = [ "openid" ]
    token_endpoint = "https://auth.pingone.com/${pingone_environment.environment_3.id}/as/token"
  }

  icon = {
    id   = pingone_image.environment_3_logo.id
    href = pingone_image.environment_3_logo.uploaded_image.href
  }
}

resource "pingone_identity_provider" "im_environment_4_identity_provider" {
  environment_id = pingone_environment.internal_master_environment.id
  registration_population_id = pingone_population.im_environment_4_population.id
  name    = var.environment_name_4
  enabled = true

  openid_connect = {
    client_id = pingone_application.environment_4_titan_solutions.oidc_options.client_id
    client_secret = pingone_application_secret.environment_4_titan_solutions_secret.secret
    authorization_endpoint = "https://auth.pingone.com/${pingone_environment.environment_4.id}/as/authorize"
    issuer = "https://auth.pingone.com/${pingone_environment.environment_4.id}/as"
    jwks_endpoint = "https://auth.pingone.com/${pingone_environment.environment_4.id}/as/jwks"
    scopes = [ "openid" ]
    token_endpoint = "https://auth.pingone.com/${pingone_environment.environment_4.id}/as/token"
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
    pkce_method = "S256"
  }

    icon = {
    id   = pingone_image.environment_4_logo.id
    href = pingone_image.environment_4_logo.uploaded_image.href
  }
}

resource "pingone_identity_provider" "im_oidc2_identity_provider" {
  environment_id = pingone_environment.internal_master_environment.id
  registration_population_id = pingone_population.im_titanid_population.id
  name    = "OIDC2"
  enabled = true

  openid_connect = {
    client_id = pingone_application.im_partner_oidc_extidp_app.oidc_options.client_id
    client_secret = pingone_application_secret.im_partner_oidc_extidp_secret.secret
    authorization_endpoint = "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/authorize"
    issuer = "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as"
    jwks_endpoint = "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/jwks"
    scopes = [ "openid" ]
    token_endpoint = "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/token"
  }
}

###########################################################
#  Internal Master Environment - Authentication Policies  #
###########################################################

resource "pingone_sign_on_policy" "im_id_first_authentication_policy" {
  environment_id = pingone_environment.internal_master_environment.id

  name        = "IdFirst"
}

resource "pingone_sign_on_policy_action" "im_identifier_first" {
  environment_id    = pingone_environment.internal_master_environment.id
  sign_on_policy_id = pingone_sign_on_policy.im_id_first_authentication_policy.id

  priority = 1

  conditions {
    last_sign_on_older_than_seconds = 1800 // 30 minutes
  }

  identifier_first {
    recovery_enabled = true
  }

  social_provider_ids = [pingone_identity_provider.im_environment_4_identity_provider.id]
}

#############################################
#  Internal Master Environment - Languages  #
#############################################

data "pingone_language" "spanish" {
  environment_id = pingone_environment.internal_master_environment.id

  locale = "es"
}

resource "pingone_language_update" "spanish" {
  environment_id = pingone_environment.internal_master_environment.id

  language_id = data.pingone_language.spanish.id
  enabled     = true
  default     = false
}

###############################################
#  Internal Master Environment - Credentials  #
###############################################

resource "pingone_credential_type" "im_internal_access_credential_type" {
  environment_id   = pingone_environment.internal_master_environment.id
  title            = "InternalAccess"
  description      = "Internal Access Credential"
  card_type        = "InternalAccess"
  revoke_on_delete = true
  management_mode  = "MANAGED"

  card_design_template = <<-EOT
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 480">
<rect fill="none" width="736" height="476" stroke="#CACED3" stroke-width="3" rx="10" ry="10" x="2" y="2"></rect>
<rect fill="$${cardColor}" height="476" rx="10" ry="10" width="736" x="2" y="2"></rect>
<image href="$${backgroundImage}" style="opacity:50%" height="476" rx="10" ry="10" width="736" x="2" y="2"></image>
<image href="$${logoImage}" x="42" y="43" height="90px" width="90px"></image>
<line y2="160" x2="695" y1="160" x1="42.5" stroke="$${textColor}"></line>
<text fill="$${textColor}" font-weight="450" font-size="30" x="160" y="90">$${cardTitle}</text>
<text fill="$${textColor}" font-size="25" font-weight="300" x="160" y="130">$${cardSubtitle}</text>
<image href="data:image/jpeg;base64,$${fields[0].value}" x="590" y="30" height="120px" width="120px"></image>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="278">$${fields[2].value}</text>
</svg>
EOT

  metadata = {
    name               = "InternalAccess"
    description        = "Internal Access Credential"
    bg_opacity_percent = 0

    background_image = pingone_image.credentials_background_image.uploaded_image.href
    logo_image       = pingone_image.credentials_logo_image.uploaded_image.href

    card_color = "#ffffff"
    text_color = "#E53935"

    fields = [
      {
        type       = "Alphanumeric Text"
        title      = "selfie"
        is_visible = true
        required   = false
      },
      {
        type       = "Directory Attribute"
        title      = "unique_identifier"
        attribute  = "id"
        is_visible = false
        required   = false
      },
      {
        type       = "Alphanumeric Text"
        title      = "verifiers"
        is_visible = true
        required   = false
      },
      {
        type       = "Alphanumeric Text"
        title      = "accessType"
        is_visible = true
        required   = false
      }     
    ]
  }
}

resource "pingone_credential_type" "im_verified_employee_credential_type" {
  environment_id   = pingone_environment.internal_master_environment.id
  title            = "VerifiedEmployee"
  card_type        = "VerifiedEmployee"
  revoke_on_delete = true

  card_design_template = <<-EOT
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 480">
<rect fill="none" width="736" height="476" stroke="#CACED3" stroke-width="3" rx="10" ry="10" x="2" y="2"></rect>
<rect fill="$${cardColor}" height="476" rx="10" ry="10" width="736" x="2" y="2"></rect>
<image href="$${backgroundImage}" style="opacity:50%" height="476" rx="10" ry="10" width="736" x="2" y="2"></image>
<image href="$${logoImage}" x="42" y="43" height="90px" width="90px"></image>
<line y2="160" x2="695" y1="160" x1="42.5" stroke="$${textColor}"></line>
<text fill="$${textColor}" font-weight="450" font-size="30" x="160" y="90">$${cardTitle}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="228">$${fields[0].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="278">$${fields[1].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="328">$${fields[2].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="378">$${fields[3].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="428">$${fields[4].value}</text>
</svg>
EOT

  metadata = {
    name               = "VerifiedEmployee"
    bg_opacity_percent = 0

    background_image = pingone_image.credentials_background_image.uploaded_image.href
    logo_image       = pingone_image.credentials_logo_image.uploaded_image.href

    card_color = "#ffffff"
    text_color = "#000000"

    fields = [
      {
        type       = "Directory Attribute"
        title      = "givenName"
        attribute  = "name.given"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "surname"
        attribute  = "name.family"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "displayName"
        attribute  = "name.formatted"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "mail"
        attribute  = "email"
        is_visible = true
      },      
      {
        type       = "Directory Attribute"
        title      = "jobTitle"
        attribute  = "title"
        is_visible = true
      }
    ]
  }
}

resource "pingone_credential_issuance_rule" "im_verified_employee_credential_issuance_rule" {
  environment_id                = pingone_environment.internal_master_environment.id
  credential_type_id            = pingone_credential_type.im_verified_employee_credential_type.id

  status = "ACTIVE"

  filter = {
    population_ids = [pingone_population.im_employee_creds_population.id]
  }

  automation = {
    issue  = "PERIODIC"
    revoke = "PERIODIC"
    update = "PERIODIC"
  }

  notification = {
    methods = ["EMAIL", "SMS"]
    template = {
      locale  = "en"
      variant = "credential_issued_template_B"
    }
  }
}

###########################################
#  Interal Master Environment - Branding  #
###########################################

resource "pingone_image" "im_idfirst_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/idfirst-icon.jpg")
}

resource "pingone_image" "im_titanid_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/titanid-solutions-icon.png")
}

resource "pingone_image" "im_titanid_app_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/titanid-solutions-app-icon.png")
}

resource "pingone_branding_theme" "im_titanid_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "TitanID"
  template = "default"

  logo = {
    id   = pingone_image.im_titanid_logo.id
    href = pingone_image.im_titanid_logo.uploaded_image.href
  }

  background_color   = "#4B4E57"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#4B4E57"
  card_color         = "#FFFFFF"
  body_text_color    = "#4B4E57"
  link_text_color    = "#4B4E57"
  button_color       = "#4B4E57"
}

resource "pingone_branding_theme_default" "im_theme_active" {
  environment_id = pingone_environment.internal_master_environment.id

  branding_theme_id = pingone_branding_theme.im_titanid_theme.id
}

resource "pingone_image" "im_blueshield_systems_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/blueshield-systems-icon.png")
}

resource "pingone_branding_theme" "im_blueshield_systems_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "BlueShield"
  template = "default"

  logo = {
    id   = pingone_image.im_blueshield_systems_logo.id
    href = pingone_image.im_blueshield_systems_logo.uploaded_image.href
  }

  background_color   = "#264064"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#264064"
  card_color         = "#FFFFFF"
  body_text_color    = "#686F77"
  link_text_color    = "#264064"
  button_color       = "#264064"
}

resource "pingone_image" "im_crimson_trust_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/crimson-trust-icon.png")
}

resource "pingone_branding_theme" "im_crimson_trust_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "CrimsonTrust"
  template = "default"

  logo = {
    id   = pingone_image.im_crimson_trust_logo.id
    href = pingone_image.im_crimson_trust_logo.uploaded_image.href
  }

  background_color   = "#BA0003"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#BA0003"
  card_color         = "#FFFFFF"
  body_text_color    = "#000000"
  link_text_color    = "#BA0003"
  button_color       = "#BA0003"
}

resource "pingone_image" "im_verde_persona_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/verde-persona-icon.png")
}

resource "pingone_image" "im_verde_persona_app_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/verde-persona-app-icon.png")
}

resource "pingone_branding_theme" "im_verde_persona_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "VerdePersona"
  template = "default"

  logo = {
    id   = pingone_image.im_verde_persona_logo.id
    href = pingone_image.im_verde_persona_logo.uploaded_image.href
  }

  background_color   = "#D6E2D6"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#333333"
  card_color         = "#EFEDE2"
  body_text_color    = "#333333"
  link_text_color    = "#4CAF50"
  button_color       = "#377542"
}

resource "pingone_image" "im_environment_3_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/silver-surfers-icon.png")
}

resource "pingone_branding_theme" "im_environment_3_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "SilverSurfers"
  template = "split"

  logo = {
    id   = pingone_image.environment_3_logo.id
    href = pingone_image.environment_3_logo.uploaded_image.href
  }

  background_color   = "#F3F3F3"
  button_text_color  = "#F3F3F3"
  heading_text_color = "#CCCCCC"
  card_color         = "#5A5A5A"
  body_text_color    = "#C0C0C0"
  link_text_color    = "#CCCCCC"
  button_color       = "#C0C0C0"
}

resource "pingone_image" "im_environment_4_logo" {
  environment_id = pingone_environment.internal_master_environment.id

  image_file_base64 = filebase64("./images/golden-gate-icon.png")
}

resource "pingone_branding_theme" "im_environment_4_theme" {
  environment_id = pingone_environment.internal_master_environment.id

  name     = "GoldenGate"
  template = "default"

  logo = {
    id   = pingone_image.environment_4_logo.id
    href = pingone_image.environment_4_logo.uploaded_image.href
  }

  background_color   = "#F3F3F3"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#C4A902"
  card_color         = "#FFFFFF"
  body_text_color    = "#686F77"
  link_text_color    = "#C4A902"
  button_color       = "#0A0A0A"
}

#############################################
#  Interal Master Environment - Agreements  #
#############################################

data "pingone_language" "en" {
  environment_id = pingone_environment.internal_master_environment.id
  locale = "en"
}

resource "pingone_agreement" "im_titanid_agreement" {
  environment_id = pingone_environment.internal_master_environment.id

  name        = "TitanID Agreement"
}

resource "pingone_agreement_localization" "im_titanid_agreement_en" {
  environment_id = pingone_environment.internal_master_environment.id
  agreement_id   = pingone_agreement.im_titanid_agreement.id
  language_id    = data.pingone_language.en.id

  display_name = "TitanID Agreement - English Locale"

  # This allows you to rename your environment and do things like that without triggering a re-create on this, which errors because we need a localization
  lifecycle {
    ignore_changes = all
  }
}

# resource "time_offset" "now" { 
#   offset_seconds = 60
# }

resource "pingone_agreement_localization_revision" "im_titanid_agreement_en_now" {
  environment_id            = pingone_environment.internal_master_environment.id
  agreement_id              = pingone_agreement.im_titanid_agreement.id
  agreement_localization_id = pingone_agreement_localization.im_titanid_agreement_en.id

  # effective_at      = time_offset.now.rfc3339
  content_type      = "text/plain"
  require_reconsent = true
  text              = var.pingone_agreement_localization_revision_im_titanid_agreement_en_now_text
}

resource "pingone_agreement_localization_enable" "im_titanid_agreement_en_enable" {
  environment_id            = pingone_environment.internal_master_environment.id
  agreement_id              = pingone_agreement.im_titanid_agreement.id
  agreement_localization_id = pingone_agreement_localization.im_titanid_agreement_en.id

  enabled = true

  depends_on = [
    pingone_agreement_localization_revision.im_titanid_agreement_en_now
  ]
}

resource "pingone_agreement_enable" "im_titanid_agreement_enable" {
  environment_id = pingone_environment.internal_master_environment.id
  agreement_id   = pingone_agreement.im_titanid_agreement.id

  enabled = true

  depends_on = [
    pingone_agreement_localization_enable.im_titanid_agreement_en_enable
  ]
}

###################################################
#  Interal Master Environment - Protect Policies  #
###################################################

resource "pingone_risk_policy" "im_risk_policy" {
  environment_id = pingone_environment.internal_master_environment.id

  name = "${var.environment_name_master} Risk Policy"

  policy_scores = {
    policy_threshold_medium = {
      min_score = 40
    }

    policy_threshold_high = {
      min_score = 75
    }

    predictors = [
      {
        compact_name = "anonymousNetwork"
        score        = 50
      },
      {
        compact_name = "geoVelocity"
        score        = 50
      },
      {
        compact_name = "ipRisk"
        score        = 50
      },
            {
        compact_name = "ipVelocityByUser"
        score        = 75
      },
            {
        compact_name = "userVelocityByIp"
        score        = 75
      },
            {
        compact_name = "userBasedRiskBehavior"
        score        = 75
      },
            {
        compact_name = "newDevice"
        score        = 75
      },
      {
        compact_name = "userLocationAnomaly"
        score        = 50
      },
      {
        compact_name = "botDetection"
        score        = 80
      },
      {
        compact_name = "suspiciousDevice"
        score        = 80
      },
      {
        compact_name = "adversaryInTheMiddle"
        score        = 80
      },
      {
        compact_name = "trafficAnomaly"
        score        = 80
      }
    ]
  }
}

#####################################################
#  Interal Master Environment - Email Templates  #
#####################################################

resource "pingone_notification_template_content" "devicePairingEN" {
  environment_id = pingone_environment.internal_master_environment.id
  template_name  = "device_pairing"
  locale         = "en"

  email = {
    body    = "${file("${path.module}/email_templates/devicePairing_EN.html")}"
    subject = "PingOne: Finish pairing your device"
    content_type  = "text/html"
    character_set = "UTF-8"

  
  }
}

resource "pingone_notification_template_content" "devicePairingES" {
  environment_id = pingone_environment.internal_master_environment.id
  template_name  = "device_pairing"
  locale         = "es"

  email = {
    body    = "${file("${path.module}/email_templates/devicePairing_ES.html")}"
    subject = "PingOne: Finish pairing your device"
    content_type  = "text/html"
    character_set = "UTF-8"

  
  }
}

resource "pingone_notification_template_content" "strongAuthEN" {
  environment_id = pingone_environment.internal_master_environment.id
  template_name  = "strong_authentication"
  locale         = "en"

  email = {
    body    = "${file("${path.module}/email_templates/strongAuth_EN.html")}"
    subject = "PingOne: New authentication request"
    content_type  = "text/html"
    character_set = "UTF-8"

  }
}

resource "pingone_notification_template_content" "strongAuthES" {
  environment_id = pingone_environment.internal_master_environment.id
  template_name  = "strong_authentication"
  locale         = "es"

  email = {
    body    = "${file("${path.module}/email_templates/strongAuth_ES.html")}"
    subject = "PingOne: New authentication request"
    content_type  = "text/html"
    character_set = "UTF-8"

  }
}



#############################
#  Credentials Environment  #
#############################

resource "pingone_environment" "credentials_environment" {         
  name        = var.environment_name_credentials
  type        = var.environment_type
  license_id  = var.license_id != "" ? var.license_id : data.pingone_licenses.internal_license.ids[0]

  services = [
    {
      type = "SSO"
    },
    {
      type = "PingID"
    },
    {
      type = "DaVinci",
      tags  = ["DAVINCI_MINIMAL"]
    },
      {
      type = "Verify"
    },    
    {
      type = "Credentials"
    }
  ]
}

############################################
#  Credentials Environment - Data Sources  #
############################################

data "pingone_digital_wallet_application" "pingid_mobile_digital_wallet" {
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingID Mobile"

  depends_on = [ pingone_population_default.credentials_default_population ]
}

###########################################
#  Credentials Environment - Populations  #
###########################################

resource "pingone_population_default" "credentials_default_population" {
  environment_id = pingone_environment.credentials_environment.id

  name        = "Default"
  description = "A default population"
}

resource "pingone_population" "credentials_partners_population" {
  environment_id = pingone_environment.credentials_environment.id
  
  name        = "Partners"
  description = "A population for Partner users"
}

############################################
#  Credentials Environment - Applications  #
############################################

resource "pingone_system_application" "credentials_pingone_portal" {
  environment_id = pingone_environment.credentials_environment.id

  type    = "PING_ONE_PORTAL"
  enabled = true
}

resource "pingone_application_flow_policy_assignment" "credentials_pingone_portal" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = pingone_system_application.credentials_pingone_portal.id

  flow_policy_id = davinci_application_flow_policy.Verified-Employee-Internal-Access.id

  priority = 1
}

resource "pingone_system_application" "credentials_pingone_self_service" {
  environment_id = pingone_environment.credentials_environment.id

  type    = "PING_ONE_SELF_SERVICE"
  enabled = true

  apply_default_theme         = true
  enable_default_theme_footer = true
}

resource "pingone_application_flow_policy_assignment" "credentials_pingone_self_service" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = pingone_system_application.credentials_pingone_self_service.id

  flow_policy_id = davinci_application_flow_policy.Verified-Partner-Internal-Access.id

  priority = 1
}

resource "pingone_key" "credentials_signing_key" {
  environment_id = pingone_environment.credentials_environment.id

  name                = "Credentials Signing Key"
  algorithm           = "RSA"
  key_length          = 4096
  signature_algorithm = "SHA512withRSA"
  subject_dn          = "CN=Credentials Signing Key, OU=Sales Engineering, L=, ST=, C=US"
  usage_type          = "SIGNING"
  validity_period     = 365
}

resource "pingone_application" "saml_decoder_app" {
  environment_id = pingone_environment.credentials_environment.id
  name           = "Facile Decoder"
  enabled        = true

  saml_options = {
    acs_urls           = ["https://decoder.pingidentity.cloud/saml"]
    assertion_duration = 3600
    sp_entity_id       = "https://decoder.pingidentity.cloud/saml"

    idp_signing_key = {
      key_id    = pingone_key.credentials_signing_key.id
      algorithm = pingone_key.credentials_signing_key.signature_algorithm
    }
  }
}

resource "pingone_application_flow_policy_assignment" "credentials_saml_decoder_app" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = pingone_application.saml_decoder_app.id

  flow_policy_id = davinci_application_flow_policy.Verify-Internal-Access.id

  priority = 1
}

resource "pingone_application" "credentials_dv_worker_app" {
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingOne DaVinci Connection"
  enabled        = true

  oidc_options = {
    type                        = "WORKER"
    grant_types                 = ["CLIENT_CREDENTIALS"]
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
  }

  icon = {
    id   = "c6dbb456-0857-4fab-bfb0-909944233017"
    href = "https://assets.pingone.com/ux/ui-library/4.18.0/images/logo-pingidentity.png"
  }
}

resource "pingone_application_secret" "credentials_dv_worker_secret" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = pingone_application.credentials_dv_worker_app.id
}

##########################################
#  Credentials Environment - MFA Policy  #
##########################################

# resource "pingone_mfa_device_policy" "credentials_mfa_device_policy" {
#   environment_id = pingone_environment.credentials_environment.id
#   name           = "Credentials MFA Policy"

#   mobile = {
#     enabled = true
#   }

#   totp = {
#     enabled = false
#   }

#   fido2 = {
#     enabled = true
#   }

#   sms = {
#     enabled = false
#   }

#   voice = {
#     enabled = false
#   }

#   email = {
#     enabled = false
#   }
# }

###########################################
#  Credentials Environment - Credentials  #
###########################################

resource "pingone_image" "credentials_background_image" {
  environment_id    = pingone_environment.credentials_environment.id
  image_file_base64 = filebase64("./images/transparent.png")
}

resource "pingone_image" "credentials_logo_image" {
  environment_id    = pingone_environment.credentials_environment.id
  image_file_base64 = filebase64("./images/pingone-logo.png")
}

resource "pingone_credential_type" "internal_access_credential_type" {
  environment_id   = pingone_environment.credentials_environment.id
  title            = "InternalAccess"
  description      = "Internal Access Credential"
  card_type        = "InternalAccess"
  revoke_on_delete = true
  management_mode  = "MANAGED"

  card_design_template = <<-EOT
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 480">
<rect fill="none" width="736" height="476" stroke="#CACED3" stroke-width="3" rx="10" ry="10" x="2" y="2"></rect>
<rect fill="$${cardColor}" height="476" rx="10" ry="10" width="736" x="2" y="2"></rect>
<image href="$${backgroundImage}" style="opacity:50%" height="476" rx="10" ry="10" width="736" x="2" y="2"></image>
<image href="$${logoImage}" x="42" y="43" height="90px" width="90px"></image>
<line y2="160" x2="695" y1="160" x1="42.5" stroke="$${textColor}"></line>
<text fill="$${textColor}" font-weight="450" font-size="30" x="160" y="90">$${cardTitle}</text>
<text fill="$${textColor}" font-size="25" font-weight="300" x="160" y="130">$${cardSubtitle}</text>
<image href="data:image/jpeg;base64,$${fields[0].value}" x="590" y="30" height="120px" width="120px"></image>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="278">$${fields[2].value}</text>
</svg>
EOT

  metadata = {
    name               = "InternalAccess"
    description        = "Internal Access Credential"
    bg_opacity_percent = 0

    background_image = pingone_image.credentials_background_image.uploaded_image.href
    logo_image       = pingone_image.credentials_logo_image.uploaded_image.href

    card_color = "#ffffff"
    text_color = "#E53935"

    fields = [
      {
        type       = "Alphanumeric Text"
        title      = "selfie"
        is_visible = true
        required   = false
      },
      {
        type       = "Directory Attribute"
        title      = "unique_identifier"
        attribute  = "id"
        is_visible = false
        required   = false
      },
      {
        type       = "Alphanumeric Text"
        title      = "verifiers"
        is_visible = true
        required   = false
      },
      {
        type       = "Alphanumeric Text"
        title      = "accessType"
        is_visible = true
        required   = false
      }     
    ]
  }
}

resource "pingone_credential_type" "verified_employee_credential_type" {
  environment_id   = pingone_environment.credentials_environment.id
  title            = "VerifiedEmployee"
  card_type        = "VerifiedEmployee"
  revoke_on_delete = true

  card_design_template = <<-EOT
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 480">
<rect fill="none" width="736" height="476" stroke="#CACED3" stroke-width="3" rx="10" ry="10" x="2" y="2"></rect>
<rect fill="$${cardColor}" height="476" rx="10" ry="10" width="736" x="2" y="2"></rect>
<image href="$${backgroundImage}" style="opacity:50%" height="476" rx="10" ry="10" width="736" x="2" y="2"></image>
<image href="$${logoImage}" x="42" y="43" height="90px" width="90px"></image>
<line y2="160" x2="695" y1="160" x1="42.5" stroke="$${textColor}"></line>
<text fill="$${textColor}" font-weight="450" font-size="30" x="160" y="90">$${cardTitle}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="228">$${fields[0].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="278">$${fields[1].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="328">$${fields[2].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="378">$${fields[3].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="428">$${fields[4].value}</text>
</svg>
EOT

  metadata = {
    name               = "VerifiedEmployee"
    bg_opacity_percent = 0

    background_image = pingone_image.credentials_background_image.uploaded_image.href
    logo_image       = pingone_image.credentials_logo_image.uploaded_image.href

    card_color = "#ffffff"
    text_color = "#000000"

    fields = [
      {
        type       = "Directory Attribute"
        title      = "givenName"
        attribute  = "name.given"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "surname"
        attribute  = "name.family"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "displayName"
        attribute  = "name.formatted"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "mail"
        attribute  = "email"
        is_visible = true
      },      
      {
        type       = "Directory Attribute"
        title      = "jobTitle"
        attribute  = "title"
        is_visible = true
      }
    ]
  }
}

resource "pingone_credential_issuance_rule" "verified_employee_credential_issuance_rule" {
  environment_id                = pingone_environment.credentials_environment.id
  digital_wallet_application_id = data.pingone_digital_wallet_application.pingid_mobile_digital_wallet.id
  credential_type_id            = pingone_credential_type.verified_employee_credential_type.id

  status = "ACTIVE"

  filter = {
    population_ids = [pingone_population_default.credentials_default_population.id]
  }

  automation = {
    issue  = "PERIODIC"
    revoke = "PERIODIC"
    update = "PERIODIC"
  }

  notification = {
    methods = ["EMAIL", "SMS"]
    template = {
      locale  = "en"
      variant = "credential_issued_template_B"
    }
  }
}

resource "pingone_credential_type" "verified_partner_credential_type" {
  environment_id   = pingone_environment.credentials_environment.id
  title            = "VerifiedPartner"
  card_type        = "VerifiedPartner"
  revoke_on_delete = true

  card_design_template = <<-EOT
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 480">
<rect fill="none" width="736" height="476" stroke="#CACED3" stroke-width="3" rx="10" ry="10" x="2" y="2"></rect>
<rect fill="$${cardColor}" height="476" rx="10" ry="10" width="736" x="2" y="2"></rect>
<image href="$${backgroundImage}" style="opacity:50%" height="476" rx="10" ry="10" width="736" x="2" y="2"></image>
<image href="$${logoImage}" x="42" y="43" height="90px" width="90px"></image>
<line y2="160" x2="695" y1="160" x1="42.5" stroke="$${textColor}"></line>
<text fill="$${textColor}" font-weight="450" font-size="30" x="160" y="90">$${cardTitle}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="228">$${fields[0].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="278">$${fields[1].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="328">$${fields[2].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="378">$${fields[3].value}</text>
<text fill="$${textColor}" font-weight="500" font-size="20" x="50" y="428">$${fields[4].value}</text>
</svg>
EOT

  metadata = {
    name               = "VerifiedPartner"
    bg_opacity_percent = 0

    background_image = pingone_image.credentials_background_image.uploaded_image.href
    logo_image       = pingone_image.credentials_logo_image.uploaded_image.href

    card_color = "#ffffff"
    text_color = "#000000"

    fields = [
      {
        type       = "Directory Attribute"
        title      = "Given Name"
        attribute  = "name.given"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "Family Name"
        attribute  = "name.family"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "Full Name"
        attribute  = "name.formatted"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "Email Address"
        attribute  = "email"
        is_visible = true
      },      
      {
        type       = "Directory Attribute"
        title      = "Type of Partner"
        attribute  = "type"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "Population ID"
        attribute  = "population.id"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "Contractor ID"
        attribute  = "accountId"
        is_visible = true
      }
    ]
  }
}

resource "pingone_credential_issuance_rule" "verified_partner_credential_issuance_rule" {
  environment_id                = pingone_environment.credentials_environment.id
  digital_wallet_application_id = data.pingone_digital_wallet_application.pingid_mobile_digital_wallet.id
  credential_type_id            = pingone_credential_type.verified_partner_credential_type.id

  status = "ACTIVE"

  filter = {
    population_ids = [pingone_population.credentials_partners_population.id]
  }

  automation = {
    issue  = "PERIODIC"
    revoke = "PERIODIC"
    update = "PERIODIC"
  }

  notification = {
    methods = ["EMAIL", "SMS"]
    template = {
      locale  = "en"
      variant = "credential_issued_template_B"
    }
  }
}

resource "pingone_webhook" "credentials_webhook" {
  environment_id          = pingone_environment.credentials_environment.id

  name                    = "Facile Decoder"
  enabled                 = true
  verify_tls_certificates = false

  http_endpoint_url       = "https://decoder.pingidentity.cloud/webhooks"

  format                  = "ACTIVITY"

  filter_options = {
    included_action_types = ["DAVINCI_INTERACTION.CUSTOM_ANALYTICS", "DAVINCI_INTERACTION.SEND_ERROR_RESPONSE", "DAVINCI_INTERACTION.START_INTERACTION", "VERIFY_APPEVENT.CREATED", "VERIFY_METADATA.CREATED", "VERIFY_METADATA.DELETED"]
  }
}

###################################
#  Environment 3 (SilverSurfers)  #
###################################

resource "pingone_environment" "environment_3" {         
  name        = var.environment_name_3
  type        = var.environment_type
  license_id  = var.license_id != "" ? var.license_id : data.pingone_licenses.internal_license.ids[0]

  services = [
    {
      type = "SSO"
    },
    {
      type = "PingID"
    },
    {
      type = "DaVinci",
      tags  = ["DAVINCI_MINIMAL"]
    }
  ]
}

#################################################
#  Environment 3 (SilverSurfers) - Populations  #
#################################################

resource "pingone_population_default" "environment_3_default_population" {
  environment_id = pingone_environment.environment_3.id

  name        = "Default"
  description = "A default population"
}



##################################################
#  Environment 3 (SilverSurfers) - Applications  #
##################################################

resource "pingone_application" "environment_3_titan_solutions" {
  environment_id = pingone_environment.environment_3.id
  enabled        = true
  name           = "TitanSolutions"

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method  = "NONE"
    redirect_uris               = ["https://auth.pingone.com/${pingone_environment.environment_3.id}/rp/callback/openid_connect"]
  }

  # icon = {
  #   id   = "c6dbb456-0857-4fab-bfb0-909944233017"
  #   href = "https://assets.pingone.com/ux/ui-library/4.18.0/images/logo-pingidentity.png"
  # }
}

resource "pingone_application_attribute_mapping" "environment_3_attribute" {
  environment_id = pingone_environment.environment_3.id
  application_id = pingone_application.environment_3_titan_solutions.id

  name  = "sub"
  value = "$${user.username}"
  required = true
}

resource "pingone_application_secret" "environment_3_titan_solutions_secret" {
  environment_id = pingone_environment.environment_3.id
  application_id = pingone_application.environment_3_titan_solutions.id
}

##############################################
#  Environment 3 (SilverSurfers) - Branding  #
##############################################

resource "pingone_image" "environment_3_logo" {
  environment_id = pingone_environment.environment_3.id
  image_file_base64 = filebase64("./images/silver-surfers-icon.png")
}

resource "pingone_branding_theme" "environment_3_theme" {
  environment_id = pingone_environment.environment_3.id

  name     = "${var.environment_name_3} Split"
  template = "split"

  logo = {
    id   = pingone_image.environment_3_logo.id
    href = pingone_image.environment_3_logo.uploaded_image.href
  }

  background_color   = "#F3F3F3"
  button_text_color  = "#F3F3F3"
  heading_text_color = "#CCCCCC"
  card_color         = "#5A5A5A"
  body_text_color    = "#C0C0C0"
  link_text_color    = "#CCCCCC"
  button_color       = "#C0C0C0"
}

resource "pingone_branding_theme_default" "environment_3_theme_active" {
  environment_id = pingone_environment.environment_3.id

  branding_theme_id = pingone_branding_theme.environment_3_theme.id
}

#################################################################
#  Environment 3 (SilverSurfers) - External Identity Providers  #
#################################################################

resource "pingone_identity_provider" "microsoft" {
  environment_id = pingone_environment.environment_3.id
  registration_population_id = pingone_population_default.environment_3_default_population.id
  name    = "Microsoft"
  enabled = true

  icon = {
    href = "https://purepng.com/public/uploads/large/purepng.com-microsoft-logo-iconlogobrand-logoiconslogos-251519939091wmudn.png"
    id   = "c6dbb456-0857-4fab-bfb0-909944233017"
  }

  # microsoft = {
  #   client_id     = var.microsoft_client_id == "" ? "client-id" : var.microsoft_client_id
  #   client_secret = var.microsoft_client_secret == "" ? "client-id" : var.microsoft_client_secret
  # }

  openid_connect = {
    authorization_endpoint = "https://az-endpoint.com"
    client_id = "client-id"
    client_secret = "client-secret"
    issuer = "https://issuer.com"
    jwks_endpoint = "https://jwks-endpoint.com"
    scopes = [ "openid" ]
    token_endpoint = "https://token-endpoint.com"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "pingone_identity_provider_attribute" "microsoft_upn" {
  environment_id       = pingone_environment.environment_3.id
  identity_provider_id = pingone_identity_provider.microsoft.id

  name   = "username"
  value  = "$${providerAttributes.userPrincipalName}"
}

resource "pingone_identity_provider_attribute" "microsoft_email" {
  environment_id       = pingone_environment.environment_3.id
  identity_provider_id = pingone_identity_provider.microsoft.id

  name   = "email"
  update = "EMPTY_ONLY"
  value  = "$${providerAttributes.email}"
}

#############################################################
#  Environment 3 (SilverSurfers) - Authentication Policies  #
#############################################################

resource "pingone_sign_on_policy" "environment_3_authentication_policy" {
  environment_id = pingone_environment.environment_3.id

  name        = "Microsoft"
}

resource "pingone_sign_on_policy_action" "microsoft_identity_provider_action" {
  environment_id    = pingone_environment.environment_3.id
  sign_on_policy_id = pingone_sign_on_policy.environment_3_authentication_policy.id

  priority = 1

  conditions {
    last_sign_on_older_than_seconds = 1800 // 30 minutes
  }

  identity_provider {
    identity_provider_id = pingone_identity_provider.microsoft.id
  }
}

## Error leaving this here until it is fixed for Microsoft IDPs:
# Error: Error when calling `CreateSignOnPolicyAction`: The request could not be completed. One or more validation errors were in the request.
# │ 
# │   with pingone_sign_on_policy_action.my_policy_identity_provider,
# │   on pingone.tf line 685, in resource "pingone_sign_on_policy_action" "my_policy_identity_provider":
# │  685: resource "pingone_sign_on_policy_action" "my_policy_identity_provider" {
# │ 
# │ PingOne Error Details:
# │ ID:           bab313b1-fc35-45ea-aae5-28bedba8b2a0
# │ Code:         INVALID_DATA
# │ Message:      The request could not be completed. One or more validation errors were in the request.
# │ Details:
# │   - Code:     INVALID_VALUE
# │     Message:  Only SAML or OIDC type IDP can be configured with 'passUserContext' property.
# │     Target:   passUserContext

#################################
#  Environment 4 (GoldenGate)  #
#################################

resource "pingone_environment" "environment_4" {         
  name        = var.environment_name_4
  #description = var.environment_description_4
  type        = var.environment_type
  license_id  = var.license_id != "" ? var.license_id : data.pingone_licenses.internal_license.ids[0]

  services = [
    {
      type = "SSO"
    },
    {
      type = "MFA"
    },
    {
      type = "DaVinci",
      tags  = ["DAVINCI_MINIMAL"]
    },
      {
      type = "Risk"
    }
  ]
}

########################################
#  Environment 4 (GoldenGate) - Users  #
########################################

resource "random_string" "im_golden_gate_string" {
  for_each = var.user_index
  length = 4
  upper = false
  special = false
  min_lower = 1
  min_numeric = 1
}

resource "pingone_user" "im_golden_gate_user" {
  for_each = var.user_index

  environment_id = pingone_environment.environment_4.id

  population_id = pingone_population_default.environment_4_default_population.id

  email    = "b2bpingdemo+user-${random_string.im_golden_gate_string[each.value].result}@maildrop.cc"
  username = "user.${each.value}@goldengate.com"
  password = {
    initial_value = "2Federate!"
  }
  name = {
    given            = "GoldenGate"
    family           = "Users ${each.value}"
  }
  mfa_enabled = true
}

##############################################
#  Environment 4 (GoldenGate) - Populations  #
##############################################

resource "pingone_population_default" "environment_4_default_population" {
  environment_id = pingone_environment.environment_4.id

  name        = "Default"
  description = "A default population"
}

###############################################
#  Environment 4 (GoldenGate) - Applications  #
###############################################

resource "pingone_application" "environment_4_titan_solutions" {
  environment_id = pingone_environment.environment_4.id
  enabled        = true
  name           = "TitanSolutions"

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method  = "NONE"
    redirect_uris               = ["https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/rp/callback/openid_connect"]
    token_endpoint_auth_method  = "CLIENT_SECRET_BASIC"
  }

  # icon = {
  #   id   = "c6dbb456-0857-4fab-bfb0-909944233017"
  #   href = "https://assets.pingone.com/ux/ui-library/4.18.0/images/logo-pingidentity.png"
  # }
}

resource "pingone_application_attribute_mapping" "environment_4_attribute" {
  environment_id = pingone_environment.environment_4.id
  application_id = pingone_application.environment_4_titan_solutions.id

  name  = "sub"
  value = "$${user.username}"
  required = true
}

resource "pingone_application_secret" "environment_4_titan_solutions_secret" {
  environment_id = pingone_environment.environment_4.id
  application_id = pingone_application.environment_4_titan_solutions.id
}

###########################################
#  Environment 4 (GoldenGate) - Branding  #
###########################################

resource "pingone_image" "environment_4_logo" {
  environment_id = pingone_environment.environment_4.id

  image_file_base64 = filebase64("./images/golden-gate-icon.png")
}

resource "pingone_branding_settings" "environment_4_branding" {
  environment_id = pingone_environment.environment_4.id

  company_name = var.environment_name_4

  logo_image = {
    id   = pingone_image.environment_4_logo.id
    href = pingone_image.environment_4_logo.uploaded_image.href
  }
}

resource "pingone_branding_theme" "environment_4_theme" {
  environment_id = pingone_environment.environment_4.id

  name     = "${var.environment_name_4} Default"
  template = "default"

  logo = {
    id   = pingone_image.environment_4_logo.id
    href = pingone_image.environment_4_logo.uploaded_image.href
  }

  background_color   = "#F3F3F3"
  button_text_color  = "#FFFFFF"
  heading_text_color = "#C4A902"
  card_color         = "#FFFFFF"
  body_text_color    = "#686F77"
  link_text_color    = "#C4A902"
  button_color       = "#0A0A0A"
}

resource "pingone_branding_theme_default" "environment_4_theme_active" {
  environment_id = pingone_environment.environment_4.id

  branding_theme_id = pingone_branding_theme.environment_4_theme.id
}

#################################################
#  Environment 4 (GoldenGate) - Protect Policy  #
#################################################

resource "pingone_risk_policy" "environment_4_risk_policy" {
  environment_id = pingone_environment.environment_4.id

  name = "${var.environment_name_4} Risk Policy"

  policy_scores = {
    policy_threshold_medium = {
      min_score = 40
    }

    policy_threshold_high = {
      min_score = 75
    }

    predictors = [
      {
        compact_name = "anonymousNetwork"
        score        = 50
      },
      {
        compact_name = "geoVelocity"
        score        = 50
      },
      {
        compact_name = "ipRisk"
        score        = 50
      },
            {
        compact_name = "adversaryInTheMiddle"
        score        = 80
      },
            {
        compact_name = "botDetection"
        score        = 80
      },
            {
        compact_name = "suspiciousDevice"
        score        = 80
      },
            {
        compact_name = "trafficAnomaly"
        score        = 80
      }
    ]
  }
}
