require 'test_helper'

class EmailValidatorTest < ActiveSupport::TestCase
  test 'GDS email addresses are allowed to sign in' do
    email = 'fname.lname@digital.cabinet-office.gov.uk'
    assert EmailValidator.email_is_allowed_basic?(email)
  end

  test 'Cabinet Office email addresses are allowed to sign in' do
    email = 'fname.lname@cabinetoffice.gov.uk'
    assert EmailValidator.email_is_allowed_basic?(email)
  end

  test 'Government Property Agency email addresses are allowed to sign in' do
    email = 'fname.lname@gpa.gov.uk'
    assert EmailValidator.email_is_allowed_basic?(email)
  end

  test 'Infrastructure and Projects Authority email addresses are allowed to sign in' do
    email = 'fname.lname@ipa.gov.uk'
    assert EmailValidator.email_is_allowed_basic?(email)
  end

  test 'IBCA email addresses are allowed to sign in' do
    email = 'fname.lname@ibca.org.uk'
    assert EmailValidator.email_is_allowed_basic?(email)
  end

  test 'Other email addresses are not allowed to sign in' do
    email = 'fname.lname@example.com'
    assert ! EmailValidator.email_is_allowed_basic?(email)
  end

  test 'GDS email addresses are allowed to manage users' do
    email = 'fname.lname@digital.cabinet-office.gov.uk'
    assert EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Cabinet Office email addresses are allowed to manage users' do
    email = 'fname.lname@cabinetoffice.gov.uk'
    assert EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Government Property Agency email addresses are allowed to manage users' do
    email = 'fname.lname@gpa.gov.uk'
    assert EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Infrastructure and Projects Authority email addresses are allowed to manage users' do
    email = 'fname.lname@ipa.gov.uk'
    assert EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'IBCA email addresses are allowed to manage users' do
    email = 'fname.lname@ibca.org.uk'
    assert EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Softwire email addresses are not allowed to manage users' do
    email = 'fname.lname@softwire.com'
    assert ! EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Fidusinfosec email addresses are not allowed to manage users' do
    email = 'fname.lname@fidusinfosec.com'
    assert ! EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Cyberis email addresses are not allowed to manage users' do
    email = 'fname.lname@cyberis.com'
    assert ! EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'Other email addresses are not allowed to manage users' do
    email = 'fname.lname@example.com'
    assert ! EmailValidator.email_is_allowed_advanced?(email)
  end

  test 'GDS emails are matched by the allowed emails regexp' do
    email = 'fname.lname@digital.cabinet-office.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Cabinet Office emails are matched by the allowed emails regexp' do
    email = 'fname.lname@cabinetoffice.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Government Property Agency emails can be used as usernames for new users' do
    email = 'fname.lname@gpa.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Infrastructure and Projects Authority emails can be used as usernames for new users' do
    email = 'fname.lname@ipa.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Softwire emails are matched by the allowed emails regexp' do
    email = 'fname.lname@softwire.com'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Fidusinfosec emails are matched by the allowed emails regexp' do
    email = 'fname.lname@fidusinfosec.com'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Cyberis emails are matched by the allowed emails regexp' do
    email = 'fname.lname@cyberis.com'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Pentestpartners emails are matched by the allowed emails regexp' do
    email = 'fname.lname@pentestpartners.com'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'IBCA emails are matched by the allowed emails regexp' do
    email = 'fname.lname@ibca.org.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Emails with numbers in the local part are allowed' do
    email = 'fname.lname1@digital.cabinet-office.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Mixed list of valid emails are matched by the allowed emails regexp' do
    emails = [
      'test.user@digital.cabinet-office.gov.uk',
      'test.user@cabinetoffice.gov.uk',
    ].join(",\n")
    assert_match EmailValidator.allowed_emails_regexp, emails
  end

  test 'Other email addresses should not match emails regexp' do
    email = 'fname.lname@example.com'
    assert_no_match EmailValidator.allowed_emails_regexp, email
  end

  test "If ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] is set then only allow the specified emails to login" do
    allowed_address = 'allowed.person@digital.cabinet-office.gov.uk'
    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert EmailValidator.email_is_allowed_basic?('notallowed.person@digital.cabinet-office.gov.uk')
    assert EmailValidator.email_is_allowed_advanced?(allowed_address)
    assert EmailValidator.email_is_allowed_advanced?('notallowed.person@digital.cabinet-office.gov.uk')

    # blank string is ignored
    ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] = " "
    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert EmailValidator.email_is_allowed_basic?('notallowed.person@digital.cabinet-office.gov.uk')
    assert EmailValidator.email_is_allowed_advanced?(allowed_address)
    assert EmailValidator.email_is_allowed_advanced?('notallowed.person@digital.cabinet-office.gov.uk')

    ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] = allowed_address
    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert ! EmailValidator.email_is_allowed_basic?('notallowed.person@digital.cabinet-office.gov.uk')
    assert EmailValidator.email_is_allowed_advanced?(allowed_address)
    assert ! EmailValidator.email_is_allowed_advanced?('notallowed.person@digital.cabinet-office.gov.uk')

    # cleanup
    ENV.delete('RESTRICT_LOGIN_EMAIL_ADDRESSES_TO')
  end
end
