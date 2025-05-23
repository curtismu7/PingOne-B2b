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
environment_name_master = "B2B_Internal_Master"
environment_description_master = "Main Flow for B2B Demo"
environment_name_credentials = "B2B_Credentials"
environment_description_credentials = "Neo demo for onboarding and validating Partners"
# Probably want to rename these to something more descriptive - not sure what makes sense right now.
environment_name_3 = "B2B_SilverSurfers"
environment_description_3 = "PingOne environment for External IDP to Microsoft"
microsoft_client_id = ""
microsoft_client_secret = ""
environment_name_4 = "B2B_GoldenGate"
environment_description_4 = "PingOne Extnernal IDP"

pingone_agreement_localization_revision_im_titanid_agreement_en_now_text = <<EOT
AI Overview
Learn more
A sports agreement, like a standard player contract, outlines the terms of employment between an athlete and a team or organization. It can cover various aspects, including duration, compensation, performance bonuses, and other financial incentives. Additionally, it can include provisions related to agent representation, athlete conduct, and dispute resolution. 
Key Elements of a Sports Agreement:
Parties Involved:
Clearly identifies the athlete, the team/organization, and any agents involved. 
Term of Contract:
Specifies the duration of the agreement, including the start and end dates. 
Compensation:
Details the athlete's salary, bonuses, and other financial incentives. 
Duties and Obligations:
Outlines the athlete's responsibilities, such as participating in games and practices, adhering to team rules, and maintaining a professional image. 
Agent Representation:
If applicable, specifies the roles and responsibilities of the athlete's agent. 
Termination Clause:
Defines the conditions under which the agreement can be terminated by either party. 
Dispute Resolution:
Outlines a process for resolving any disagreements that may arise between the parties. 
Other Important Clauses:
May include provisions related to image rights, endorsements, and other relevant aspects. 
Examples of Sports Agreements:
Player Contracts:
.
Agreements between professional athletes and their teams, often negotiated through a player union or association. 
Agent Agreements:
.
Contracts between athletes and their agents, outlining the terms of representation. 
Endorsement Agreements:
.
Agreements between athletes and sponsors, outlining the terms of endorsements and promotional activities. 
Sponsorship Agreements:
.
Agreements between teams and sponsors, outlining the terms of sponsorships and related activities. 
Coaching Agreements:
.
Agreements between coaches and teams or organizations, outlining the terms of employment and responsibilities. 
Important Considerations:
Legal Counsel:
It's crucial to seek legal advice when drafting or reviewing a sports agreement to ensure it is legally sound and protects the interests of all parties. 
Specific Terms:
The specific terms of a sports agreement will vary depending on the nature of the agreement and the parties involved. 
Negotiation:
Many sports agreements are subject to negotiation, and it's important to understand the terms and implications of each clause. 
EOT
