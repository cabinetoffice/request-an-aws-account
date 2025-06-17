module FormParams
  BASE_HASH = {
    "account_name" => "example-account",
    "account_description" => "This account is used for testing purposes.",
    "organisation" => "Example Organisation",
    "cost_centre_code" => "CC123",
    "cost_centre_description" => "Cost Centre for Digital Services",
    "business_unit" => "Digital Services",
    "subsection" => "Digital Services - Development",
    "team_name" => "Development Team",
    "team_email_address" => "dev.team@example.com",
    "team_lead_name" => "John Smith",
    "team_lead_email_address" => "john.smith@example.com",
    "team_lead_phone_number" => "+111111111111111",
    "team_lead_role" => "Team Lead",
    "service_name" => "Example Service",
    "security_requested_alert_priority_level" => "P1",
    "security_critical_resources_description" => "Contains sensitive user data.",
    "security_does_account_hold_pii" => "yes",
    "security_does_account_hold_pci_data" => "no",
    "admin_users" => "fake@email.com\r\nfake2@email.com"
  }

  def self.out_of_hours_support_true
    BASE_HASH.merge(
      "service_is_out_of_hours_support_provided" => "true",
      "out_of_hours_support_contact_name" => "John Smith",
      "out_of_hours_support_phone_number" => "+111111111111111",
      "out_of_hours_support_pagerduty_link" => "http://pagerduty.example.com",
      "out_of_hours_support_email_address" => "support@example.com"
    )
  end

  def self.out_of_hours_support_false
    BASE_HASH.merge("service_is_out_of_hours_support_provided" => "false")
  end

  def self.with_nil_value
    BASE_HASH.merge(
      "empty_field" => nil,
      "service_is_out_of_hours_support_provided" => "true",
      "out_of_hours_support_contact_name" => "John Smith",
      "out_of_hours_support_phone_number" => "+111111111111111",
      "out_of_hours_support_pagerduty_link" => "http://pagerduty.example.com",
      "out_of_hours_support_email_address" => "support@example.com"
    )
  end
end