module Tags
  def self.tags_containing_out_of_hours_support
    <<-TAGS
    "account-name"                             = "example-account"
    "description"                              = "This account is used for testing purposes."
    "organisation"                             = "Example Organisation"
    "team-name"                                = "Development Team"
    "team-email-address"                       = "dev.team@example.com"
    "team-lead-name"                           = "John Smith"
    "team-lead-email-address"                  = "john.smith@example.com"
    "team-lead-phone-number"                   = "+111111111111111"
    "team-lead-role"                           = "Team Lead"
    "service-name"                             = "Example Service"
    "service-is-out-of-hours-support-provided" = "true"
    "security-requested-alert-priority-level"  = "P1"
    "security-critical-resources-description"  = "Contains sensitive user data."
    "security-does-account-hold-pii"           = "yes"
    "security-does-account-hold-pci-data"      = "no"
    "out-of-hours-support-contact-name"        = "John Smith"
    "out-of-hours-support-phone-number"        = "+111111111111111"
    "out-of-hours-support-pagerduty-link"      = "http://pagerduty.example.com"
    "out-of-hours-support-email-address"       = "support@example.com"
    "billing-cost-centre"                      = "CC123"
    "billing-business-unit"                    = "Digital Services"
    "billing-business-unit-subsection"         = "Digital Services - Development"
    TAGS
  end
  def self.tags_without_out_of_hours_support
    <<-TAGS
    "account-name"                             = "example-account"
    "description"                              = "This account is used for testing purposes."
    "organisation"                             = "Example Organisation"
    "team-name"                                = "Development Team"
    "team-email-address"                       = "dev.team@example.com"
    "team-lead-name"                           = "John Smith"
    "team-lead-email-address"                  = "john.smith@example.com"
    "team-lead-phone-number"                   = "+111111111111111"
    "team-lead-role"                           = "Team Lead"
    "service-name"                             = "Example Service"
    "service-is-out-of-hours-support-provided" = "false"
    "security-requested-alert-priority-level"  = "P1"
    "security-critical-resources-description"  = "Contains sensitive user data."
    "security-does-account-hold-pii"           = "yes"
    "security-does-account-hold-pci-data"      = "no"
    "billing-cost-centre"                      = "CC123"
    "billing-business-unit"                    = "Digital Services"
    "billing-business-unit-subsection"         = "Digital Services - Development"
    TAGS
  end
end