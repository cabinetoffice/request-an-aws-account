module AlternateContacts
  ALTERNATE_CONTACT_EMAIL_ADDRESS = "placeholder@email.com"
  ALTERNATE_CONTACT_PHONE_NUMBER = "+111111111111"
  
  def self.alternate_contacts
    <<-ALTERNATE_CONTACTS
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
  end
end