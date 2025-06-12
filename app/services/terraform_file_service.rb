class TerraformFileService
  AWS_ROOT_ACCOUNTS_EMAIL_FORMAT = "aws-root+%s@cabinetoffice.gov.uk"
  ALTERNATE_CONTACT_EMAIL_ADDRESS = "placeholder@email.com"
  ALTERNATE_CONTACT_PHONE_NUMBER = "+111111111111"
  ORGANISATION_UNIT = "Workloads ou-mcdg-wg49h2bw"

  def create_account_terraform_file(form_params, email)

    account_name = form_params['account_name']
    admin_users = form_params['admin_users']

    tags = generate_tags(form_params)
    alternate_contacts = generate_alternate_contacts()
    admin_users = generate_admin_users(admin_users)

    account_terraform_file = <<~TF
    module "#{account_name}" {
      source = "./modules/aft-account-request"
    
      control_tower_parameters = {
        AccountEmail = "#{AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % account_name}"
        AccountName  = "#{account_name}"

        # Syntax for top-level OU
        ManagedOrganizationalUnit = "#{ORGANISATION_UNIT}"
        # Syntax for nested OU
        # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    
        SSOUserEmail     = "null"
        SSOUserFirstName = "null"
        SSOUserLastName  = "null"
      }

      account_tags = {
    #{tags}  }

      change_management_parameters = {
        change_requested_by = "#{email}"
        change_reason       = ""
      }

      custom_fields = {
    #{alternate_contacts}
    #{admin_users}  }

      account_customizations_name = "#{account_name}"
    }
  TF

    return account_terraform_file
  end

  def generate_tags(form_params)
    base_tags = <<-TAGS
    "account-name"                             = "#{form_params['account_name']}"
    "description"                              = "#{form_params['account_description']}"
    "organisation"                             = "#{form_params['organisation']}"
    "team-name"                                = "#{form_params['team_name']}"
    "team-email-address"                       = "#{form_params['team_email_address']}"
    "team-lead-name"                           = "#{form_params['team_lead_name']}"
    "team-lead-email-address"                  = "#{form_params['team_lead_email_address']}"
    "team-lead-phone-number"                   = "#{form_params['team_lead_phone_number']}"
    "team-lead-role"                           = "#{form_params['team_lead_role']}"
    "service-name"                             = "#{form_params['service_name']}"
    "service-is-out-of-hours-support-provided" = "#{form_params['service_is_out_of_hours_support_provided']}"
    "security-requested-alert-priority-level"  = "#{form_params['security_requested_alert_priority_level']}"
    "security-critical-resources-description"  = "#{form_params['security_critical_resources_description']}"
    "security-does-account-hold-pii"           = "#{form_params['security_does_account_hold_pii']}"
    "security-does-account-hold-pci-data"      = "#{form_params['security_does_account_hold_pci_data']}"
    TAGS

    out_of_hours_tags = ''
    if form_params['service_is_out_of_hours_support_provided'] == 'true'
      out_of_hours_tags = <<-OUT_OF_HOURS_TAGS
    "out-of-hours-support-contact-name"        = "#{form_params['out_of_hours_support_contact_name']}"
    "out-of-hours-support-phone-number"        = "#{form_params['out_of_hours_support_phone_number']}"
    "out-of-hours-support-pagerduty-link"      = "#{form_params['out_of_hours_support_pagerduty_link']}"
    "out-of-hours-support-email-address"       = "#{form_params['out_of_hours_support_email_address']}"
    OUT_OF_HOURS_TAGS
    end
  
    billing_tags = <<-BILLING_TAGS
    "billing-cost-centre"                      = "#{form_params['cost_centre_code']}"
    "billing-business-unit"                    = "#{form_params['business_unit']}"
    "billing-business-unit-subsection"         = "#{form_params['subsection']}"
    BILLING_TAGS
  
    final_tags = base_tags + out_of_hours_tags + billing_tags

    return final_tags
  end

  def generate_alternate_contacts()
    alternate_contacts = <<-ALTERNATE_CONTACTS
    alternate_contact = jsonencode(
      {
        "billing" = {
          "email-address" = "#{ALTERNATE_CONTACT_EMAIL_ADDRESS}",
          "name"          = "Account Receiveable",
          "phone-number"  = "#{ALTERNATE_CONTACT_PHONE_NUMBER}",
          "title"         = "Billing Department"
        },
        "operations" = {
          "email-address" = "#{ALTERNATE_CONTACT_EMAIL_ADDRESS}",
          "name"          = "Operations 24/7",
          "phone-number"  = "#{ALTERNATE_CONTACT_PHONE_NUMBER}",
          "title"         = "DevOps Team"
        },
        "security" = {
          "email-address" = "#{ALTERNATE_CONTACT_EMAIL_ADDRESS}",
          "name"          = "Security Ops Center",
          "phone-number"  = "#{ALTERNATE_CONTACT_PHONE_NUMBER}",
          "title"         = "SOC Team"
        }
      }
    )
    ALTERNATE_CONTACTS
    return alternate_contacts
  end

  def generate_admin_users(admin_users)

    sanitised_admin_users = admin_users.split(/[\r\n]+/).reject(&:empty?)

    admin_users = <<-ADMIN_USERS
    admin_users = jsonencode(#{sanitised_admin_users})
    ADMIN_USERS

    return admin_users
  end
end