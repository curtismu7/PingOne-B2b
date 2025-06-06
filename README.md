# PingOne B2B Demo Environment

> [!TIP]
> Want cleaner, easier to follow documentation? Check out the [Confluence Page](https://pingidentity.atlassian.net/wiki/x/vQWMXg) instead!

## Table of Contents
- [PingOne B2B Demo Environment](#pingone-b2b-demo-environment)
  - [Table of Contents](#table-of-contents)
    - [Prerequisites](#prerequisites)
      - [Configure PingOne](#configure-pingone)
    - [Install Terraform](#install-terraform)
    - [Download and extract the latest release from Github](#download-and-extract-the-latest-release-from-github)
    - [Update the TFVars File](#update-the-tfvars-file)
    - [Apply the Terraform Configuration](#apply-the-terraform-configuration)
    - [Additional Documentation](#additional-documentation)
      - [QuickStart for set up and running the demo](#QuickStart-for-Set-up-and-Running-PingOne-B2B-demo)
      - [Full PingOne B2B Documentation for Set up and running the demo](#Full-set-up-documentation-and-running-the-PingOne-B2B-Demo)
      - [Delegated Admininstration guide for PingOne](#Delegated-Admin-overview-in-PingOne)



    

### Prerequisites

#### Configure PingOne

In your Administrators environment, create a new group. Name it whatever you would like. Suggestion: **PingOne B2B Administrators**
> [!WARNING]
Add your own admin account to this group. Do not provide it with any Roles.

You will need the Group ID from this group and the Environment ID of the Administrators environment.
<img src="https://github.com/user-attachments/assets/28ea7018-f9dd-45d3-85cf-51b9c15319f0" width="500">
> [!WARNING]
> Terraform will reach back into the administrators environment and use this group to provide permissions to the environments it creates for Administrators. Once Terraform has added Roles to this group, you will no longer be able to add or remove yourself from the group. If this happens, you can still create another Administator account, sign into it and provide your initial account with access.

Create a new PingOne environment with the PingOne SSO and PingOne DaVinci services. Name it whatever you like. Suggestion: **Terrform Administration**. \
This environment will only be used to allow Terraform to create and manage new environments within PingOne.
<img src="https://github.com/curtismu7/Master-Flow/assets/117233001/81e61e41-df67-4c3a-ab42-2f9c6855a519" width="500">

In your new environment, create a worker application. Name it whatever you like. Suggestion: **Pingone Terrform Administration**. \
Enable it.\
Navigate to the Roles tab and provide it with the following permissions.
> [!WARNING]
> Do not assign Environment Admin permissions at the Organization level. The Terraform configuration will add any permissions needed to maintain the environments it creates moving forward. If you apply Environment Admin permissions at the Organization level, Terraform will error out with a message about duplicate permissions.
<img src="https://github.com/user-attachments/assets/c86b8175-ee5f-4a05-aca1-d4e2dcac2ab0" width="500"> 
<br />

In your new environment, create a user. Its email address must be reachable, but its username and all other attributes may be anything you desire. \
Navigate to the Roles tab and provide this user with the following permissions.
> [!WARNING]
> Do not apply DaVinci Admin rights at the Organization level. The Terraform configuration will add any permissions needed to maintain the environments it creates moving forward.
<img src="https://github.com/curtismu7/Master-Flow/assets/117233001/8ce0bd20-1e78-4389-9bad-cd58ee7d0ec9" width="500">
<br />

Navigate to Applications -> Applications, select "PingOne Self-Service - MyAccount", and then choose "Overview". Using the URL from "Home Page URL", sign in as this user and execute a password reset. Once the user's password has been reset, you can log out of the PingOne Dock. If you do not reset their password, you will see errors relating to the user's credentials later.

Keep this environment handy. We will need to get a number of IDs from it later.

### Install Terraform

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) from the linked documentation. Recommendation: Use Homebrew for macOS and Chocolatey for Windows.

### Download and extract the latest release from Github

```bash
mkdir -p ~/terraform/pingone-b2b && cd ~/terraform/pingone-b2b
curl -L https://github.com/curtismu7/PingOne-B2b/releases/download/1.0.3/tf-release.zip > tf-release.zip
unzip ./tf-release.zip && rm ./tf-release.zip
```

### Update the TFVars File
Update the `terraform.tfvars` file for your environment. For the default experience, you will not need to modify anything below the DaVinci header.

Variables from the *Terraform Administration* environment: \
`worker_id`      - The client id from the worker app in the **Terraform Administration** environment that you created. \
`worker_secret`  - The client secret from the worker the **Terraform Administration** environment that you created. \
`pingone_environment_id` - The environment ID of the **Terraform Administration** environment that you created. \
`region`               - Options are `AsiaPacific` `Canada` `Europe` and `NorthAmerica` \
`license_id`         - The license ID that you would like to use. If left blank, it will default to the license used for the environment that you created. \
`admin_user_id`        - The id of the user account that you created. This can be found on the API tab of your user. \
`admin_username`    - The username of the user account that you created. \
`admin_password`    - The password of the user account that you created. \
`organization_id`      - The id of your PingOne organization. \

Variables from the *Administrators* \
`admin_environment_id`  - The environment ID of the **Administrators** environment. \
`admin_group_id`          - The group ID of the group you created in the **Administrators** environment. \

### Apply the Terraform Configuration

In the same directory as before, initialize your Terraform provider.
```bash
terraform init
```

Plan your Terraform deployment. This should provide you with a message about how many resources this configuration will create on your behalf. 
```bash
terraform plan
```

Apply your Terraform configuration, deploying all of the resources specified in your configuration.
```bash
terraform apply --auto-approve
```
> [!WARNING]
> The following warning is expected, and should not impact functionality.
> ```╷
> │ Warning: Generated effective_at value used
> │ 
> │   with pingone_agreement_localization_revision.im_titanid_agreement_en_now,
> │   on pingone.tf line 1752, in resource "pingone_agreement_localization_revision" "im_titanid_agreement_en_now":
> │ 1752: resource "pingone_agreement_localization_revision" "im_titanid_agreement_en_now" {
> │ 
> │ No effective_at value was provided; defaulted to: 2025-05-27T13:36:26Z
> ╵```

Destroy your environment when you are done with it.
```bash
terraform destroy --auto-approve
```

> [!WARNING]
> If you see the following error while attempting to destroy and environment:
> ```
> ╷
> │ Error: Invalid parameter value - Unmappable identity provider type
> │ 
> │ The identity provider ID provided (b738f367-e828-4f76-9ab8-1ed4e843ecf7) relates to an unknown type.  Attributes cannot be mapped to this identity provider.
> ╵
> ```
> Run the following command and then re-run the destroy command above:
> ```
> terraform state rm pingone_identity_provider_attribute.microsoft_upn
> ```

### Additional Documentation

#### QuickStart for Set up and Running PingOne B2B demo

Quick Start Document: [Google Docs Link](https://docs.google.com/document/d/1nVVA6z3z2PLFvLel8H3RWHrlAielcVvlxA9x4gq6gFg/edit?tab=t.0#heading=h.ifiudsrxn4wk)

#### Full set up documentation and running the PingOne B2B Demo

Full Documentation: [Google Docs Link](https://docs.google.com/document/d/1Aa5crAcIrL-EeWnY5j9K_Ka9dmWedaTqMXb-I1bLfLs/edit?tab=t.0#heading=h.lkp6jhck5x9i)

#### Delegated Admin overview in PingOne

Delegated Admin documentation: [Google Docs Link](https://docs.google.com/document/d/1_Yewn_P7gXx0HzyImY952Po--7AFpfBDyj-au-3be1U/edit?tab=t.0#heading=h.ndzfhdfx9269)

#### Diagram showing Environments 

<img src="https://github.com/curtismu7/CDN/blob/main/PingOne%20B2B%20Model%20(1).png?raw=true" width="600">


Diagram:  [Github Link to diagram](https://github.com/curtismu7/CDN/blob/main/PingOne%20B2B%20Model%20(1).png?raw=true)
