require 'test_helper'
require 'webmock'

ACCOUNT_MANAGEMENT_GITHUB_API = "https://api.github.com/repos/cabinetoffice/cope-aws-account-billing-test"

class CheckYourAnswersControllerTest < ActionDispatch::IntegrationTest
  include WebMock::API
  setup {
    WebMock.enable!
    set_stub_env_vars
    set_session(
      'test@example.com',
      'account_name' => 'some-name',
      'account_description' => 'some account description',

      'organisation' => 'Cabinet Office',
      'business_unit' => 'some-business-unit',
      'subsection' => 'some-subsection',
      'cost_centre_code' => '87654321',
      'cost_centre_description' => 'cost-centre',

      'team_name' => 'Platform Health',
      'team_email_address' => 'foo@example.com',
      'team_lead_name' => 'Team Lead',
      'team_lead_email_address' => 'team-lead@example.com',
      'team_lead_phone_number' => '00000000000',
      'team_lead_role' => 'Developer',

      'service_name' => 'GOV.UK',
      'service_is_out_of_hours_support_provided' => 'true',

      'out_of_hours_support_contact_name' => 'Support Contact',
      'out_of_hours_support_phone_number' => '000000000000',
      'out_of_hours_support_pagerduty_link' => 'https://pagerduty.example.com',
      'out_of_hours_support_email_address' => 'outofhours@example.com',

      'security_requested_alert_priority_level' => 'P1',
      'security_critical_resources_description' => 'User data stored in blah S3 bucket',
      'security_does_account_hold_pii' => 'true',
      'security_does_account_hold_pci_data' => 'false'
    )
  }

  teardown {
    WebMock.reset!
    WebMock.disable!
    reset_env_vars
  }

  test 'should get index' do
    get check_your_answers_url
    assert_response :success
  end

  test 'should raise a PR for a new account with Cabinet Office cost centre info, email the users and redirect with the PR url in session' do
    accounts_terraform_before = build_content_request({ resource: [] })
    stub_notify_emails
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")
    post check_your_answers_url

    accounts_terraform_after = assert_content_updated(ACCOUNT_MANAGEMENT_GITHUB_API, '/terraform/accounts.tf')
    assert_equal(
      {
        "some-name" => {
          "name" => "some-name",
          "email" => "aws-root-accounts+some-name@digital.cabinet-office.gov.uk",
          "role_name" => "bootstrap",
          "iam_user_access_to_billing" => "ALLOW",
          "tags" => {
            "account-name" => "some-name",
            "description" => "some account description",
            "organisation" => "Cabinet Office",
            "team-name" => "Platform Health",
            "team-email-address" => "foo@example.com",
            "team-lead-name" => "Team Lead",
            "team-lead-email-address" => "team-lead@example.com",
            "team-lead-phone-number" => "00000000000",
            "team-lead-role" => "Developer",
            "service-name" => "GOV.UK",
            "service-is-out-of-hours-support-provided" => "true",
            "security-requested-alert-priority-level" => "P1",
            "security-critical-resources-description" => "User data stored in blah S3 bucket",
            "security-does-account-hold-pii" => "true",
            "security-does-account-hold-pci-data" => "false",
            "out-of-hours-support-contact-name" => "Support Contact",
            "out-of-hours-support-phone-number" => "000000000000",
            "out-of-hours-support-pagerduty-link" => "https://pagerduty.example.com",
            "out-of-hours-support-email-address" => "outofhours@example.com",
            "billing-cost-centre" => "87654321",
            "billing-business-unit" => "some-business-unit",
            "billing-business-unit-subsection" => "some-subsection"      
          }
        }
      },
      accounts_terraform_after['resource'][0]['aws_organizations_account']
    )

    emails = assert_notify_emails_sent
    assert_equal(2, emails.length)
    assert_equal(
      %w(gds-aws-account-management@digital.cabinet-office.gov.uk test@example.com).to_set,
      emails.map{|e|e['email_address']}.to_set
    )

    assert_redirected_to confirmation_account_url
    assert_equal "https://some-new-account-pull-request-url", read_from_session("pull_request_url")
  end

  test 'should raise a PR for a new account without Cabinet Office cost centre info, email the users and redirect with the PR url in session' do
    set_session(
      'test@example.com',
      'account_name' => 'some-name',
      'account_description' => 'some account description',

      'organisation' => 'Government Property Agency',

      'team_name' => 'Platform Health',
      'team_email_address' => 'foo@example.com',
      'team_lead_name' => 'Team Lead',
      'team_lead_email_address' => 'team-lead@example.com',
      'team_lead_phone_number' => '00000000000',
      'team_lead_role' => 'Developer',

      'service_name' => 'GOV.UK',
      'service_is_out_of_hours_support_provided' => 'true',

      'out_of_hours_support_contact_name' => 'Support Contact',
      'out_of_hours_support_phone_number' => '000000000000',
      'out_of_hours_support_pagerduty_link' => 'https://pagerduty.example.com',
      'out_of_hours_support_email_address' => 'outofhours@example.com',

      'security_requested_alert_priority_level' => 'P1',
      'security_critical_resources_description' => 'User data stored in blah S3 bucket',
      'security_does_account_hold_pii' => 'true',
      'security_does_account_hold_pci_data' => 'false'
    )
  

    accounts_terraform_before = build_content_request({ resource: [] })
    stub_notify_emails
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")
    post check_your_answers_url

    accounts_terraform_after = assert_content_updated(ACCOUNT_MANAGEMENT_GITHUB_API, '/terraform/accounts.tf')
    assert_equal(
      {
        "some-name" => {
          "name" => "some-name",
          "email" => "aws-root-accounts+some-name@digital.cabinet-office.gov.uk",
          "role_name" => "bootstrap",
          "iam_user_access_to_billing" => "ALLOW",
          "tags" => {
            "account-name" => "some-name",
            "description" => "some account description",
            "organisation" => "Government Property Agency",
            "team-name" => "Platform Health",
            "team-email-address" => "foo@example.com",
            "team-lead-name" => "Team Lead",
            "team-lead-email-address" => "team-lead@example.com",
            "team-lead-phone-number" => "00000000000",
            "team-lead-role" => "Developer",
            "service-name" => "GOV.UK",
            "service-is-out-of-hours-support-provided" => "true",
            "security-requested-alert-priority-level" => "P1",
            "security-critical-resources-description" => "User data stored in blah S3 bucket",
            "security-does-account-hold-pii" => "true",
            "security-does-account-hold-pci-data" => "false",
            "out-of-hours-support-contact-name" => "Support Contact",
            "out-of-hours-support-phone-number" => "000000000000",
            "out-of-hours-support-pagerduty-link" => "https://pagerduty.example.com",
            "out-of-hours-support-email-address" => "outofhours@example.com"
          }
        }
      },
      accounts_terraform_after['resource'][0]['aws_organizations_account']
    )

    assert_equal "https://some-new-account-pull-request-url", read_from_session("pull_request_url")
  end

  test 'should raise a PR for a new account without Cabinet Office cost centre info and without out of hours support info' do
    set_session(
      'test@example.com',
      'account_name' => 'some-name',
      'account_description' => 'some account description',

      'organisation' => 'Government Property Agency',

      'team_name' => 'Platform Health',
      'team_email_address' => 'foo@example.com',
      'team_lead_name' => 'Team Lead',
      'team_lead_email_address' => 'team-lead@example.com',
      'team_lead_phone_number' => '00000000000',
      'team_lead_role' => 'Developer',

      'service_name' => 'GOV.UK',
      'service_is_out_of_hours_support_provided' => 'no',

      'security_requested_alert_priority_level' => 'P1',
      'security_critical_resources_description' => 'User data stored in blah S3 bucket',
      'security_does_account_hold_pii' => 'true',
      'security_does_account_hold_pci_data' => 'false'
    )
  

    accounts_terraform_before = build_content_request({ resource: [] })
    stub_notify_emails
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")
    post check_your_answers_url

    accounts_terraform_after = assert_content_updated(ACCOUNT_MANAGEMENT_GITHUB_API, '/terraform/accounts.tf')
    assert_equal(
      {
        "some-name" => {
          "name" => "some-name",
          "email" => "aws-root-accounts+some-name@digital.cabinet-office.gov.uk",
          "role_name" => "bootstrap",
          "iam_user_access_to_billing" => "ALLOW",
          "tags" => {
            "account-name" => "some-name",
            "description" => "some account description",
            "organisation" => "Government Property Agency",
            "team-name" => "Platform Health",
            "team-email-address" => "foo@example.com",
            "team-lead-name" => "Team Lead",
            "team-lead-email-address" => "team-lead@example.com",
            "team-lead-phone-number" => "00000000000",
            "team-lead-role" => "Developer",
            "service-name" => "GOV.UK",
            "service-is-out-of-hours-support-provided" => "no",
            "security-requested-alert-priority-level" => "P1",
            "security-critical-resources-description" => "User data stored in blah S3 bucket",
            "security-does-account-hold-pii" => "true",
            "security-does-account-hold-pci-data" => "false"
          }
        }
      },
      accounts_terraform_after['resource'][0]['aws_organizations_account']
    )

    assert_equal "https://some-new-account-pull-request-url", read_from_session("pull_request_url")
  end

  test 'should handle the case where there is missing session data' do
    accounts_terraform_before = build_content_request({ resource: [] })
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")

    set_session(
      'test@example.com',
      'account_name' => 'some-name'
    )

    post check_your_answers_url

    assert_response 200
  end

  def stub_create_account_github_api(accounts_terraform, resulting_pull_request_url)
    stub_request(:get, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/commits/master").
      to_return(status: 200, body: '{"sha":"somesha"}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/git/refs").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/contents/terraform/accounts.tf.json").
     to_return(status: 404, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/contents/terraform/accounts.tf").
     to_return(status: 200, body: accounts_terraform, headers: {'Content-Type' => 'application/json'})

    stub_request(:put, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/contents/terraform/accounts.tf").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/pulls").
      to_return(status: 200, body: '{"html_url": "' + resulting_pull_request_url + '"}', headers: {'Content-Type' => 'application/json'})
  end
end
