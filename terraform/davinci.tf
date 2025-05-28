#######################################################
#  Internal Master Environment - DaVinci Connections  #
#######################################################

data "davinci_connections" "read_connections" {
  environment_id = pingone_environment.internal_master_environment.id

  connector_ids = [
    "annotationConnector", 
    "challengeConnector", 
    "codeSnippetConnector",
    "errorConnector", 
    "flowConnector", 
    "functionsConnector", 
    "genericConnector",
    "httpConnector", 
    "nodeConnector",
    "pingOneSSOConnector",
    "pingOneAuthenticationConnector",
    "pingOneMfaConnector",
	"pingOneCredentialsConnector",
    "notificationsConnector",
    "pingOneRiskConnector",
    "pingOneVerifyConnector",
    "variablesConnector",
    "devicePolicyConnector",
    "stringsConnector",
	"analyticsConnector"
  ]
}

resource "davinci_connection" "Annotation" {
  connector_id   = "annotationConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Annotation"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Challenge" {
  connector_id   = "challengeConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Challenge"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Code-Snippet" {
  environment_id = pingone_environment.internal_master_environment.id

  connector_id = "codeSnippetConnector"
  name         = "gvVariableParse"

  property {
    name  = "code"
    type  = "string"
    value = <<-EOT
// Write your code here
// Supported language: Javascript 
module.exports = a = async ({ params }) => {
	// const variableObject = JSON.parse(params.companyVariable);
	// return {'variables': variableObject}
	if (!params.companyVariable) {
		return false;
	}

	const variableObject = JSON.parse(params.companyVariable);
	return { variables: variableObject };
}
    EOT
  }

  property {
    name  = "inputSchema"
    type  = "string"
    value = <<-EOT
    {
	"input": {
		"type": "object",
		"properties": {
			"companyVariable": {
				"type": "string"
			}
		}
	}
}
EOT
  }

  property {
    name  = "outputSchema"
    type  = "string"
    value = <<-EOT
{
	"output": {
		"type": "object",
		"properties": {
			"variables": {
				"type": "object",
				"properties": {
					"_links": {
						"type": "object",
						"properties": {
							"self": {
								"type": "object",
								"properties": {
									"href": {
										"type": "string"
									}
								}
							}
						}
					},
					"_embedded": {
						"type": "object",
						"properties": {
							"themes": {
								"type": "array",
								"items": []
							}
						}
					},
					"size": {
						"type": "integer"
					}
				}
			}
		}
	}
}
    EOT
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Error-Message" {
  connector_id   = "errorConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Error Message"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Flow-Connector" {
  connector_id   = "flowConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Flow Connector"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Flow-Analytics" {
  connector_id   = "analyticsConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Flow Analytics"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Functions" {
  connector_id   = "functionsConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Functions"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Generic" {
  connector_id   = "genericConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "OIDC & OAuth IdP"

  property {
    name  = "customAuth"
    type  = "json"
    value = jsonencode({
  "properties": {
    "providerName": {
      "displayName": "Provider Name",
      "preferredControlType": "textField",
      "required": true,
      "value": "Theme Worker"
    },
    "authTypeDropdown": {
      "displayName": "Auth Type",
      "preferredControlType": "dropDown",
      "required": true,
      "options": [
        {
          "name": "Oauth2",
          "value": "oauth2"
        },
        {
          "name": "OpenId",
          "value": "openId"
        }
      ],
      "enum": [
        "oauth2",
        "openId"
      ],
      "value": "oauth2"
    },
    "skRedirectUri": {
      "displayName": "Redirect URL",
      "preferredControlType": "textField",
      "disabled": true,
      "initializeValue": "SINGULARKEY_REDIRECT_URI",
      "copyToClip": true
    },
    "issuerUrl": {
      "preferredControlType": "textField",
      "displayName": "Issuer URL",
      "info": "Required if auth type is OpenID",
      "value": "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as"
    },
    "authorizationEndpoint": {
      "displayName": "Authorization Endpoint",
      "preferredControlType": "textField",
      "required": true,
      "value": "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/authorize"
    },
    "tokenEndpoint": {
      "displayName": "Token Endpoint",
      "preferredControlType": "textField",
      "required": true,
      "value": "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/token"
    },
    "bearerToken": {
      "preferredControlType": "textField",
      "type": "boolean",
      "displayName": "Token Attachment",
      "info": "Optional field. Prepend token with this value. Example: Bearer or Token"
    },
    "userInfoEndpoint": {
      "displayName": "User Info Endpoint",
      "preferredControlType": "textFieldArrayView",
      "required": true,
      "value": [
        "https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/as/userinfo"
      ]
    },
    "clientId": {
      "displayName": "App ID",
      "preferredControlType": "textField",
      "required": true,
      "value": "${pingone_application.im_theme_worker_app.oidc_options.client_id}"
    },
    "clientSecret": {
      "displayName": "Client Secret",
      "preferredControlType": "textField",
      "secure": true,
      "required": true,
      "value": "${pingone_application_secret.im_theme_worker_secret.secret}"
    },
    "scope": {
      "displayName": "Scope",
      "preferredControlType": "textField",
      "required": true,
      "value": "openid"
    },
    "userConnectorAttributeMapping": {
      "type": "object",
      "displayName": null,
      "preferredControlType": "userConnectorAttributeMapping",
      "newMappingAllowed": true,
      "title1": null,
      "title2": null,
      "sections": [
        "attributeMapping"
      ]
    },
    "customAttributes": {
      "type": "array",
      "displayName": "Connector Attributes",
      "preferredControlType": "tableViewAttributes",
      "info": "These attributes will be available in User Connector Attribute Mapping.",
      "sections": [
        "connectorAttributes"
      ],
      "value": [
        {
          "name": "id",
          "description": "ID",
          "type": "string",
          "value": null,
          "minLength": "1",
          "maxLength": "300",
          "required": true,
          "attributeType": "sk"
        },
        {
          "name": "name",
          "description": "Display Name",
          "type": "string",
          "value": null,
          "minLength": "1",
          "maxLength": "250",
          "required": false,
          "attributeType": "sk"
        },
        {
          "name": "email",
          "description": "Email",
          "type": "string",
          "value": null,
          "minLength": "1",
          "maxLength": "250",
          "required": false,
          "attributeType": "sk"
        }
      ]
    },
    "returnToUrl": {
      "displayName": "Application Return To URL",
      "preferredControlType": "textField",
      "info": "When using the embedded flow player widget and an IdP/Social Login connector, provide a callback URL to return back to the application."
    }
  }
})
  }

   depends_on = [
    pingone_application_secret.im_theme_worker_secret,
    pingone_user_role_assignment.davinci_admin
  ] 
}

resource "davinci_connection" "Http" {
  connector_id   = "httpConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Http"
  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Node" {
  connector_id   = "nodeConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Teleport"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Strings" {
  connector_id   = "stringsConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Strings"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Device-Policy" {
  connector_id   = "devicePolicyConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Device Policy"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "PingOne" {
  connector_id   = "pingOneSSOConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "PingOne-Authentication" {
  connector_id   = "pingOneAuthenticationConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne Authentication"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "PingOne-MFA" {
  connector_id   = "pingOneMfaConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne MFA"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

   depends_on = [
    pingone_application_secret.im_dv_worker_secret,
    pingone_user_role_assignment.davinci_admin
  ] 
}

resource "davinci_connection" "PingOne-Notifications" {
  connector_id   = "notificationsConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne Notifications"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "PingOne-Protect" {
  connector_id   = "pingOneRiskConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne Protect"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

   depends_on = [
    pingone_application_secret.im_dv_worker_secret,
    pingone_user_role_assignment.davinci_admin
  ] 
}

resource "davinci_connection" "PingOne-Verify" {
  connector_id   = "pingOneVerifyConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne Verify"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "PingOne-Credentials" {
  connector_id   = "pingOneCredentialsConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "PingOne Credentials"

  property {
    name  = "clientId"
    value = pingone_application.im_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.im_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.internal_master_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Token-Management" {
  connector_id   = "skOpenIdConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Token Management"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "User-Policy" {
  connector_id   = "userPolicyConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "User Policy"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Variables" {
  connector_id   = "variablesConnector"
  environment_id = pingone_environment.internal_master_environment.id
  name           = "Variables"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

#####################################################
#  Internal Master Environment - DaVinci Variables  #
#####################################################

resource "davinci_variable" "workerId" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "workerId"
  type           = "string"
  value          = pingone_application.im_dv_worker_app.oidc_options.client_id

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "workerSecret" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "workerSecret"
  type           = "secret"
  value          = pingone_application_secret.im_dv_worker_secret.secret
  
  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "cv-ThemeObject" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "cv-ThemeObject"
  description    = "Object to hold the Theme Object"
  type           = "string"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "cv-riskPolicyId" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "cv-riskPolicyId"
  description    = "Company Variable for Risk Policy" 
  type           = "string"
  value          = pingone_risk_policy.im_risk_policy.id

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "requestedCredentialKeys" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "requestedCredentialKeys"
  description    = "Optional. If not defined, all keys are returned. Comma-delimited list of requested credential keys if specific keys from the credential are desired." 
  type           = "string"
depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "requestedCredentialType" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "requestedCredentialType"
  description    = "Type of credential to verify. Must be the name of a PingOne credential type issued by the credential issuer." 
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "trustedIssuers" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "trustedIssuers"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "requestMessage" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "requestMessage"
  description    = "Request message to display on the credential wallet, if supported."
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "credentialTypeId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "credentialTypeId"
  type           = "string"
  value          = pingone_credential_type.im_verified_employee_credential_type.id

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "p1PopulationId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "p1PopulationId"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "gv-byPassMFADate" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "gv-byPassMFADate"
  description    = "Date at which bypassing MFA registration is allowed. [YYYY-MM-DD]"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "gv-allowedBackUpMethods" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "gv-allowedBackUpMethods"
  description    = "Variable for allowed backup Methods for PingID - Only options available are SMS, Voice and Email. Example: ['SMS', 'EMAIL', 'VOICE']"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "themeObject" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "themeObject"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "isMandatoryFlow" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "isMandatoryFlow"
  type           = "boolean"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "cardColor" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "cardColor"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "canChangeDevice" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "canChangeDevice"
  description    = "Internal variable" 
  type           = "boolean"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "devices" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "devices"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "pingIdCopyrightFooter" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "pingIdCopyrightFooter"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "preppedDevices" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "preppedDevices"
  description    = "Internal variable"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "publicKeyCredentialRequestOptions" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "publicKeyCredentialRequestOptions"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "showRegButton" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "showRegButton"
  type           = "boolean"
  value          = false

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "webAuthNSupport" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "webAuthNSupport"
  description    = "Flow variable for the type of WebAuthN supported for the end user"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "deviceCount" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "deviceCount"
  description    = "Internal variable"
  type           = "number"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "adminMessage" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "adminMessage"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "numberOfOTPRetries" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "numberOfOTPRetries"
  description    = "Defines the number of incorrect OTP entries allowed"
  type           = "number"
  value          = 3

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "numberMatching" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "numberMatching"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "p1DeviceAuthenticationStatus" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "p1DeviceAuthenticationStatus"
  description    = "Defines the authentication action the user should preform"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "p1DeviceId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "p1DeviceId"
  description    = "local device ID variable to manage the most current user device being used"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "selectedDeviceIcon" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "selectedDeviceIcon"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "selectedDeviceType" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "selectedDeviceType"
  description    = "Selected device type to register"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "gv-pingIdFooterMessage" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "gv-pingIdFooterMessage"
  description    = "The copyright message for your Footer within PingID"
  type           = "string"
  value          = "Copyright © 2003-2024 Ping Identity Corporation. All rights reserved."

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "IsActionReg" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "IsActionReg"
  description    = "Internal variable"
  type           = "boolean"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "numberOfRetries" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "numberOfRetries"
  type           = "number"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "rpid" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "rpid"
  description    = "Relying Party ID"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "selectedDeviceId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "selectedDeviceId"
  description    = "Internal variable"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "OTPFallback" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "OTPFallback"
  description    = "When true a push timeout flow should continue to an OTP page"
  type           = "boolean"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "origin" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "origin"
  description    = "FIDO2 origin"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "useCode" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "useCode"
  description    = "When true the 'Use Code' button will be displayed during a mobile app authentication"
  type           = "boolean"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "p1UserId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "p1UserId"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "p1DeviceAuthenticationId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "p1DeviceAuthenticationId"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "gv-VariableObject" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "gv-VariableObject"
  description    = "Variable to hold all main ping company objects"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "selectedDeviceText" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "selectedDeviceText"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "riskEvaluationId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "riskEvaluationId"
  description    = "The Evaluation ID from the Risk Evaluation"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "riskLevel" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "riskLevel"
  description    = "Level for the PingOne Protect Evaluation"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "riskRecommendedAction" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "riskRecommendedAction"
  description    = "Recommended Action for Risk Eval"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "riskObject" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "riskObject"
  description    = "The object from the Risk Evaluation, if needed for later"
  type           = "object"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "buttonColor" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "buttonColor"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "companyIdentifier" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "companyIdentifier"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "backgroundColor" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "backgroundColor"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "themeId" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "themeId"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "themeWorkerId" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "themeWorkerId"
  type           = "string"
  value          = pingone_application.im_theme_worker_app.oidc_options.client_id

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "themeWorkerSecret" {
  context        = "company"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "themeWorkerSecret"
  type           = "secret"
  value          = pingone_application_secret.im_theme_worker_secret.secret

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "companyName" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "companyName"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_variable" "companyLogo" {
  context        = "flowInstance"
  environment_id = pingone_environment.internal_master_environment.id
  mutable        = "true"
  name           = "companyLogo"
  description    = "Url for company's logo image"
  type           = "string"

    depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

########################################################
#  Internal Master Environment - DaVinci Applications  #
########################################################

resource "davinci_application" "PingOne-SSO-Connection" {
  api_key_enabled = "true"
  environment_id  = pingone_environment.internal_master_environment.id
  name            = "PingOne SSO Connection"

  oauth {
    enabled = "true"

    values {
      allowed_grants                = ["authorizationCode"]
      allowed_scopes                = ["openid", "profile"]
      enabled                       = "true"
      enforce_signed_request_openid = "false"
      redirect_uris                 = ["https://auth.pingone.com/${pingone_environment.internal_master_environment.id}/rp/callback/openid_connect"]
    }
  }
}

resource "davinci_application_flow_policy" "PingOne-SSO-Flow-Policy" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = davinci_application.PingOne-SSO-Connection.id
  name           = "PingOne - Sign On and Registration"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.PingOne-Session-Main-Flow.id
    version_id = -1
    weight     = 100
  }
}

resource "davinci_application_flow_policy" "B2B-Alternate" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = davinci_application.PingOne-SSO-Connection.id
  name           = "B2B - Alternate"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.B2B-Demo-Flow.id
    version_id = -1
    weight     = 100
  }
}

resource "davinci_application_flow_policy" "Dummy-App" {
  environment_id = pingone_environment.internal_master_environment.id
  application_id = davinci_application.PingOne-SSO-Connection.id
  name           = "Dummy App"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.Dummy-App-Interface.id
    version_id = -1
    weight     = 100
  }
}

#################################################
#  Internal Master Environment - DaVinci Flows  #
#################################################

resource "davinci_flow" "PingOne-Session-Main-Flow" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/PingOne_Session Main Flow.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Flow-Connector.id
		name = davinci_connection.Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
	connection_link {
		id   = davinci_connection.PingOne-Authentication.id
		name = davinci_connection.PingOne-Authentication.name
		replace_import_connection_id = "c3e6a164bde107954e93f5c09f0c8bce"
	}

	subflow_link {
		id   = davinci_flow.PingOne-Sign-On-With-Registration-Password-Reset-and-Recovery.id
		name = davinci_flow.PingOne-Sign-On-With-Registration-Password-Reset-and-Recovery.name
		replace_import_subflow_id = "253db38b908492e90b5559963eb567a2"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "PingOne-Sign-On-With-Registration-Password-Reset-and-Recovery" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/PingOne_Sign On with Registration, Password Reset and Recovery.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Error-Message.id
		name = davinci_connection.Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
	connection_link {
		id   = davinci_connection.PingOne.id
		name = davinci_connection.PingOne.name
		replace_import_connection_id = "94141bf2f1b9b59a5f5365ff135e02bb"
	}
    connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
    connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "B2B-Demo-Flow" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/B2B_Flow Demo.json")}"

	lifecycle {
	  ignore_changes = all
	}
    connection_link {
		id   = davinci_connection.PingOne.id
		name = davinci_connection.PingOne.name
		replace_import_connection_id = "94141bf2f1b9b59a5f5365ff135e02bb"
	}
	connection_link {
		id   = davinci_connection.Flow-Connector.id
		name = davinci_connection.Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
    connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.PingOne-Authentication.id
		name = davinci_connection.PingOne-Authentication.name
		replace_import_connection_id = "c3e6a164bde107954e93f5c09f0c8bce"
	}
  connection_link {
		id   = davinci_connection.PingOne-MFA.id
		name = davinci_connection.PingOne-MFA.name
		replace_import_connection_id = "b72bd44e6be8180bd5988ac74cd9c949"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
    connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
    connection_link {
		id   = davinci_connection.Code-Snippet.id
		name = davinci_connection.Code-Snippet.name
		replace_import_connection_id = "fd832a43c8b719d39d57ba1079dc1bea"
	}
    connection_link {
		id   = davinci_connection.Error-Message.id
		name = davinci_connection.Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}

	subflow_link {
		id   = davinci_flow.SubFlow-A-P1MFA-Device-Authentication.id
		name = davinci_flow.SubFlow-A-P1MFA-Device-Authentication.name
		replace_import_subflow_id = "9f135677f3f1ed894017f93a38eec556"
	}
    subflow_link {
		id   = davinci_flow.SubFlow-C-P1MFA-Device-Registration.id
		name = davinci_flow.SubFlow-C-P1MFA-Device-Registration.name
		replace_import_subflow_id = "a11734ea34fd27745f19e2335ffa2c31"
	}
    subflow_link {
		id   = davinci_flow.SubFlow-Risk-Evaluation.id
		name = davinci_flow.SubFlow-Risk-Evaluation.name
		replace_import_subflow_id = "40253015f6bbd356bd9dd5c95b816051"
	}
    subflow_link {
		id   = davinci_flow.Obtain-Theme-Object.id
		name = davinci_flow.Obtain-Theme-Object.name
		replace_import_subflow_id = "aa66043a926651df81adcb6286d5e0c6"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "SubFlow-A-P1MFA-Device-Authentication" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/[SubFlow_- A] P1MFA Device Authentication.json")}"

	lifecycle {
	  ignore_changes = all
	}
    connection_link {
		id   = davinci_connection.PingOne-MFA.id
		name = davinci_connection.PingOne-MFA.name
		replace_import_connection_id = "b72bd44e6be8180bd5988ac74cd9c949"
	}
	connection_link {
		id   = davinci_connection.Flow-Connector.id
		name = davinci_connection.Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
    connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.PingOne-Authentication.id
		name = davinci_connection.PingOne-Authentication.name
		replace_import_connection_id = "c3e6a164bde107954e93f5c09f0c8bce"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
    connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
    connection_link {
		id   = davinci_connection.Error-Message.id
		name = davinci_connection.Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}

    subflow_link {
		id   = davinci_flow.SubFlow-C-P1MFA-Device-Registration.id
		name = davinci_flow.SubFlow-C-P1MFA-Device-Registration.name
		replace_import_subflow_id = "a11734ea34fd27745f19e2335ffa2c31"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "SubFlow-C-P1MFA-Device-Registration" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/[SubFlow_- C] P1MFA Device Registration _ [N_a].json")}"

	lifecycle {
	  ignore_changes = all
	}
    connection_link {
		id   = davinci_connection.PingOne-MFA.id
		name = davinci_connection.PingOne-MFA.name
		replace_import_connection_id = "b72bd44e6be8180bd5988ac74cd9c949"
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
    connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
    connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
    connection_link {
		id   = davinci_connection.Error-Message.id
		name = davinci_connection.Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "SubFlow-Risk-Evaluation" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/[SubFlow_- B] Risk Evaluation _ [N_a].json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Annotation.id
		name = davinci_connection.Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
    connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
    connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
    connection_link {
		id   = davinci_connection.PingOne-Protect.id
		name = davinci_connection.PingOne-Protect.name
		replace_import_connection_id = "292873d5ceea806d81373ed0341b5c88"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "Obtain-Theme-Object" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/Obtain_Theme Object.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Generic.id
		name = davinci_connection.Generic.name
		replace_import_connection_id = "3b51289bf0126ac190d61284920d99e4"
	}
    connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "eIDP-Onboarding" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/eIDP_Onboarding.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Generic.id
		name = davinci_connection.Generic.name
		replace_import_connection_id = "3b51289bf0126ac190d61284920d99e4"
	}
  connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
  connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
  connection_link {
		id   = davinci_connection.Node.id
		name = davinci_connection.Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
  connection_link {
		id   = davinci_connection.Error-Message.id
		name = davinci_connection.Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}

	depends_on = [
		data.davinci_connections.read_connections
	]
}

resource "davinci_flow" "Dummy-App-Interface" {
	environment_id = pingone_environment.internal_master_environment.id
	flow_json = "${file("${path.module}/flows/Dummy_App interface.json")}"

	lifecycle {
	  ignore_changes = all
	}
  connection_link {
		id   = davinci_connection.Http.id
		name = davinci_connection.Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
  connection_link {
		id   = davinci_connection.Functions.id
		name = davinci_connection.Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
  connection_link {
		id   = davinci_connection.PingOne-Authentication.id
		name = davinci_connection.PingOne-Authentication.name
		replace_import_connection_id = "c3e6a164bde107954e93f5c09f0c8bce"
	}
  connection_link {
		id   = davinci_connection.PingOne.id
		name = davinci_connection.PingOne.name
		replace_import_connection_id = "94141bf2f1b9b59a5f5365ff135e02bb"
	}
  connection_link {
		id   = davinci_connection.Variables.id
		name = davinci_connection.Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
  connection_link {
		id   = davinci_connection.Code-Snippet.id
		name = davinci_connection.Code-Snippet.name
		replace_import_connection_id = "fd832a43c8b719d39d57ba1079dc1bea"
	}
  connection_link {
		id   = davinci_connection.Credentials-Flow-Connector.id
		name = davinci_connection.Credentials-Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}

  subflow_link {
		id   = davinci_flow.Obtain-Theme-Object.id
		name = davinci_flow.Obtain-Theme-Object.name
		replace_import_subflow_id = "aa66043a926651df81adcb6286d5e0c6"
	}
	depends_on = [
		data.davinci_connections.read_connections
	]
}


###################################################
#  Credentials Environment - DaVinci Connections  #
###################################################

data "davinci_connections" "Credentials_read_connections" {
  environment_id = pingone_environment.credentials_environment.id

  connector_ids = [
    "annotationConnector",
    "httpConnector",
    "functionsConnector",
    "flowConnector",
    "variablesConnector",
    "pingOneCredentialsConnector",
    "devicePolicyConnector",
    "nodeConnector",
    "pingOneVerifyConnector",
    "pingOneSSOConnector",
    "errorConnector",
    "stringsConnector",
    "pingOneAuthenticationConnector"
  ]
}

resource "davinci_connection" "Credentials-Annotation" {
  connector_id   = "annotationConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Annotation"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Error-Message" {
  connector_id   = "errorConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Error Message"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Flow-Connector" {
  connector_id   = "flowConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Flow Connector"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Functions" {
  connector_id   = "functionsConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Functions"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Http" {
  connector_id   = "httpConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Http"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Node" {
  connector_id   = "nodeConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Teleport"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Strings" {
  connector_id   = "stringsConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Strings"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Device-Policy" {
  connector_id   = "devicePolicyConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Device Policy"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-PingOne" {
  connector_id   = "pingOneSSOConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingOne"

  property {
    name  = "clientId"
    value = pingone_application.credentials_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.credentials_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.credentials_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-PingOne-Authentication" {
  connector_id   = "pingOneAuthenticationConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingOne Authentication"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-PingOne-Verify" {
  connector_id   = "pingOneVerifyConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingOne Verify"

  property {
    name  = "clientId"
    value = pingone_application.credentials_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.credentials_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.credentials_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-PingOne-Credentials" {
  connector_id   = "pingOneCredentialsConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "PingOne Credentials"

  property {
    name  = "clientId"
    value = pingone_application.credentials_dv_worker_app.oidc_options.client_id
  }

  property {
    name  = "clientSecret"
    value = pingone_application_secret.credentials_dv_worker_secret.secret
  }

  property {
    name  = "envId"
    value = pingone_environment.credentials_environment.id
  }

  property {
    name  = "region"
    value = var.region_code
  }

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

resource "davinci_connection" "Credentials-Variables" {
  connector_id   = "variablesConnector"
  environment_id = pingone_environment.credentials_environment.id
  name           = "Variables"

  depends_on = [ pingone_user_role_assignment.davinci_admin ]
}

####################################################
#  Credentials Environment - DaVinci Applications  #
####################################################

resource "davinci_application" "Credentials-PingOne-SSO-Connection" {
  api_key_enabled = "true"
  environment_id  = pingone_environment.credentials_environment.id
  name            = "PingOne SSO Connection"

  oauth {
    enabled = "true"

    values {
      allowed_grants                = ["authorizationCode"]
      allowed_scopes                = ["openid", "profile"]
      enabled                       = "true"
      enforce_signed_request_openid = "false"
      redirect_uris                 = ["https://auth.pingone.com/${pingone_environment.credentials_environment.id}/rp/callback/openid_connect"]
    }
  }
}

resource "davinci_application_flow_policy" "Verified-Employee-Internal-Access" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = davinci_application.Credentials-PingOne-SSO-Connection.id
  name           = "Verified Employee -> Internal Access"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.Validate-VerifiedEmployee-Flow.id
    version_id = -1
    weight     = 100
  }
}

resource "davinci_application_flow_policy" "Verified-Partner-Internal-Access" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = davinci_application.Credentials-PingOne-SSO-Connection.id
  name           = "Verified Partner -> Internal Access"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.Validate-VerifiedPartner-Flow.id
    version_id = -1
    weight     = 100
  }
}

resource "davinci_application_flow_policy" "Verify-Internal-Access" {
  environment_id = pingone_environment.credentials_environment.id
  application_id = davinci_application.Credentials-PingOne-SSO-Connection.id
  name           = "Verify Internal Access"
  status         = "enabled"

  policy_flow {
    flow_id    = davinci_flow.Verify-Internal-Access-Flow.id
    version_id = -1
    weight     = 100
  }
}

#############################################
#  Credentials Environment - DaVinci Flows  #
#############################################

resource "davinci_flow" "Validate-VerifiedEmployee-Flow" {
	environment_id = pingone_environment.credentials_environment.id
	flow_json = "${file("${path.module}/flows/Validate_VerifiedEmployee.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Credentials-Http.id
		name = davinci_connection.Credentials-Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
	connection_link {
		id   = davinci_connection.Credentials-Annotation.id
		name = davinci_connection.Credentials-Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Credentials-Functions.id
		name = davinci_connection.Credentials-Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.Credentials-Flow-Connector.id
		name = davinci_connection.Credentials-Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
    connection_link {
		id   = davinci_connection.Credentials-Variables.id
		name = davinci_connection.Credentials-Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}

	subflow_link {
		id   = davinci_flow.Validate-A-Verifiable-Credential-Subflow.id
		name = davinci_flow.Validate-A-Verifiable-Credential-Subflow.name
		replace_import_subflow_id = "b0f215d1e3835f32ccfc79044f15183f"
	}
    subflow_link {
		id   = davinci_flow.Issue-EmployeeAccess-Cred.id
		name = davinci_flow.Issue-EmployeeAccess-Cred.name
		replace_import_subflow_id = "6a21e2e98b64c0b036d44b3bc5d38544"
	}

	depends_on = [
		data.davinci_connections.Credentials_read_connections
	]
}

resource "davinci_flow" "Validate-A-Verifiable-Credential-Subflow" {
	environment_id = pingone_environment.credentials_environment.id
	flow_json = "${file("${path.module}/flows/Validate_a Verifiable Credential Subflow.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Credentials-Http.id
		name = davinci_connection.Credentials-Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
	connection_link {
		id   = davinci_connection.Credentials-Annotation.id
		name = davinci_connection.Credentials-Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Credentials-Functions.id
		name = davinci_connection.Credentials-Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.Credentials-PingOne-Credentials.id
		name = davinci_connection.Credentials-PingOne-Credentials.name
		replace_import_connection_id = "d782b51653e8b48ab04d01a43f4c8554"
	}
    connection_link {
		id   = davinci_connection.Credentials-Device-Policy.id
		name = davinci_connection.Credentials-Device-Policy.name
		replace_import_connection_id = "5914ebbf695dd3ae7c16099f2625566b"
	}
    connection_link {
		id   = davinci_connection.Credentials-Node.id
		name = davinci_connection.Credentials-Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}

	depends_on = [
		data.davinci_connections.Credentials_read_connections
	]
}

resource "davinci_flow" "Issue-EmployeeAccess-Cred" {
	environment_id = pingone_environment.credentials_environment.id
	flow_json = "${file("${path.module}/flows/Issue_EmployeeAccess Cred.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Credentials-Http.id
		name = davinci_connection.Credentials-Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
	connection_link {
		id   = davinci_connection.Credentials-Annotation.id
		name = davinci_connection.Credentials-Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Credentials-Functions.id
		name = davinci_connection.Credentials-Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
    connection_link {
		id   = davinci_connection.Credentials-Node.id
		name = davinci_connection.Credentials-Node.name
		replace_import_connection_id = "3566e86a35c26e575396dcfb89a3dcc0"
	}
	connection_link {
		id   = davinci_connection.Credentials-PingOne.id
		name = davinci_connection.Credentials-PingOne.name
		replace_import_connection_id = "94141bf2f1b9b59a5f5365ff135e02bb"
	}
    connection_link {
		id   = davinci_connection.Credentials-PingOne-Verify.id
		name = davinci_connection.Credentials-PingOne-Verify.name
		replace_import_connection_id = "0960c49c995f805c32363dedecc78fde"
	}
    connection_link {
		id   = davinci_connection.Credentials-Error-Message.id
		name = davinci_connection.Credentials-Error-Message.name
		replace_import_connection_id = "53ab83a4a4ab919d9f2cb02d9e111ac8"
	}
    connection_link {
		id   = davinci_connection.Credentials-Strings.id
		name = davinci_connection.Credentials-Strings.name
		replace_import_connection_id = "72edc71acef9a25c77bc10890d694910"
	}
    connection_link {
		id   = davinci_connection.Credentials-Variables.id
		name = davinci_connection.Credentials-Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}

	depends_on = [
		data.davinci_connections.Credentials_read_connections
	]
}

resource "davinci_flow" "Validate-VerifiedPartner-Flow" {
	environment_id = pingone_environment.credentials_environment.id
	flow_json = "${file("${path.module}/flows/Validate_Verified Partner.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Credentials-Http.id
		name = davinci_connection.Credentials-Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
	connection_link {
		id   = davinci_connection.Credentials-Annotation.id
		name = davinci_connection.Credentials-Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Credentials-Functions.id
		name = davinci_connection.Credentials-Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.Credentials-Flow-Connector.id
		name = davinci_connection.Credentials-Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
    connection_link {
		id   = davinci_connection.Credentials-Variables.id
		name = davinci_connection.Credentials-Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}

	subflow_link {
		id   = davinci_flow.Validate-A-Verifiable-Credential-Subflow.id
		name = davinci_flow.Validate-A-Verifiable-Credential-Subflow.name
		replace_import_subflow_id = "b0f215d1e3835f32ccfc79044f15183f"
	}
    subflow_link {
		id   = davinci_flow.Issue-EmployeeAccess-Cred.id
		name = davinci_flow.Issue-EmployeeAccess-Cred.name
		replace_import_subflow_id = "6a21e2e98b64c0b036d44b3bc5d38544"
	}

	depends_on = [
		data.davinci_connections.Credentials_read_connections
	]
}

resource "davinci_flow" "Verify-Internal-Access-Flow" {
	environment_id = pingone_environment.credentials_environment.id
	flow_json = "${file("${path.module}/flows/Verify_Internal Access.json")}"

	lifecycle {
	  ignore_changes = all
	}
	connection_link {
		id   = davinci_connection.Credentials-Http.id
		name = davinci_connection.Credentials-Http.name
		replace_import_connection_id = "867ed4363b2bc21c860085ad2baa817d"
	}
	connection_link {
		id   = davinci_connection.Credentials-Annotation.id
		name = davinci_connection.Credentials-Annotation.name
		replace_import_connection_id = "921bfae85c38ed45045e07be703d86b8"
	}
	connection_link {
		id   = davinci_connection.Credentials-Functions.id
		name = davinci_connection.Credentials-Functions.name
		replace_import_connection_id = "de650ca45593b82c49064ead10b9fe17"
	}
	connection_link {
		id   = davinci_connection.Credentials-Flow-Connector.id
		name = davinci_connection.Credentials-Flow-Connector.name
		replace_import_connection_id = "2581eb287bb1d9bd29ae9886d675f89f"
	}
    connection_link {
		id   = davinci_connection.Credentials-Variables.id
		name = davinci_connection.Credentials-Variables.name
		replace_import_connection_id = "06922a684039827499bdbdd97f49827b"
	}
    connection_link {
		id   = davinci_connection.Credentials-PingOne-Authentication.id
		name = davinci_connection.Credentials-PingOne-Authentication.name
		replace_import_connection_id = "c3e6a164bde107954e93f5c09f0c8bce"
	}

	subflow_link {
		id   = davinci_flow.Validate-A-Verifiable-Credential-Subflow.id
		name = davinci_flow.Validate-A-Verifiable-Credential-Subflow.name
		replace_import_subflow_id = "b0f215d1e3835f32ccfc79044f15183f"
	}

	depends_on = [
		data.davinci_connections.Credentials_read_connections
	]
}