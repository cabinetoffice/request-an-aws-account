require 'test_helper'
require 'webmock/minitest'

ACCOUNT_MANAGEMENT_GITHUB_API = "https://api.github.com/repos/org/fake-repo"

class CheckYourAnswersControllerTest < ActionDispatch::IntegrationTest
  include WebMock::API

  setup do
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
      "admin_users" => "fake@email.com\r\nfake2@email.com"
    )
    stub_notify_emails()

    Octokit::Client.any_instance.stubs(:commit).returns(stub(sha: 'some-sha'))
    Octokit::Client.any_instance.stubs(:create_ref)
    Octokit::Client.any_instance.stubs(:create_contents)
    Octokit::Client.any_instance.stubs(:create_pull_request).returns(stub(html_url: 'http://example.com/pr'))
    Octokit::Client.any_instance.stubs(:contents).raises(Octokit::NotFound)
  end

  teardown do
    WebMock.disable!
  end

  test 'should get check your answers page' do
    get check_your_answers_path
    assert_response :success
    assert_select 'h1', 'Check your answers'
  end

  test 'should submit form and redirect to confirmation page' do
    post check_your_answers_path
    assert_redirected_to confirmation_account_url
  end

  #TODO: Add more error handling tests for the CheckYourAnswersController
end