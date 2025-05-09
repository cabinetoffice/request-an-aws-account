module EmailValidator

  # which allowed domains can sign in to the Request an AWS account tool
  def self.email_is_allowed_basic?(email)
    if ENV.fetch('RESTRICT_LOGIN_EMAIL_ADDRESSES_TO', '').split(/\s+/).any?
      return false unless ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'].split(/\s+/).include?(email)
    end
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    return true if email.end_with? '@gpa.gov.uk'
    return true if email.end_with? '@ipa.gov.uk'
    return true if email.end_with? '@ibca.org.uk'
    false
  end

  # which allowed domains can request accounts
  def self.email_is_allowed_advanced?(email)
    if ENV.fetch('RESTRICT_LOGIN_EMAIL_ADDRESSES_TO', '').split(/\s+/).any?
      return false unless ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'].split(/\s+/).include?(email)
    end
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    return true if email.end_with? '@gpa.gov.uk'
    return true if email.end_with? '@ipa.gov.uk'
    return true if email.end_with? '@ibca.org.uk'
    false
  end

  # which domains are allowed to be added as administrators to new AWS accounts
  def self.allowed_emails_regexp
    /\A(#{Regexp.union(
      /([a-z0-9.\-\']+@digital\.cabinet-office\.gov\.uk,?\s*)/,
      /([a-z0-9.\-\']+@cabinetoffice\.gov\.uk,?\s*)/,
      /([a-z0-9.\-\']+@gpa\.gov\.uk,?\s*)/,
      /([a-z0-9.\-\']+@ipa\.gov\.uk,?\s*)/,
      /([a-z0-9.\-\']+@ibca\.org\.uk,?\s*)/,
    )})+\z/
  end

end
