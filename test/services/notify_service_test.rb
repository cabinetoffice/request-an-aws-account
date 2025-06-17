require 'test_helper'
require 'notifications/client'

class NotifyServiceTest < ActiveSupport::TestCase
  CONFIRMATION_EMAIL_TO_USER_NOTIFY_TEMPLATE_ID = '6e05fe05-5a6e-411e-85e0-b4e4d8dc494f'
  NOTIFICATION_EMAIL_TO_GOOGLE_GROUP_NOTIFY_TEMPLATE_ID = '25c1f81c-bcd4-46eb-bc9d-5874504c4464'

  def setup
    set_stub_env_vars()
    @notify_service = NotifyService.new
    @account_name = 'test-account'
    @pull_request_url = 'http://example.com/pr'
    @email = 'user@example.com'
    @personalisation = {
      account_name: @account_name,
      account_description: 'test description',
      email: @email,
      pull_request_url: @pull_request_url,
      admin_users: 'test admins'
    }
    Notifications::Client.any_instance.stubs(:send_email).returns(true)
  end

  def teardown
    reset_env_vars()
  end

  test 'should send an email to co-aws-requests google group if the client has a valid key' do
    Notifications::Client.any_instance.expects(:send_email).with(
      email_address: Rails.application.config.co_aws_requests_google_group,
      template_id: NOTIFICATION_EMAIL_TO_GOOGLE_GROUP_NOTIFY_TEMPLATE_ID,
      personalisation: @personalisation
    )

    @notify_service.new_account_email_co_aws_requests_google_group(@personalisation)
  end

  test 'should log a warning and return nil if NOTIFY_API_KEY is not set for co-aws-requests google group email method' do
    # Have to re-initialise the class to remove NOTIFY_API_KEY ENV var
    reset_env_vars()
    @notify_service = NotifyService.new

    Rails.logger.expects(:warn).with('Warning: no NOTIFY_API_KEY set. Skipping emails.')

    result = @notify_service.new_account_email_co_aws_requests_google_group(@personalisation)
    assert_nil result
  end

  test 'should send an email to the user' do
    Notifications::Client.any_instance.expects(:send_email).with(
      email_address: @email,
      template_id: CONFIRMATION_EMAIL_TO_USER_NOTIFY_TEMPLATE_ID,
      personalisation: {
        account_name: @account_name,
        pull_request_url: @pull_request_url
      }
    )

    @notify_service.new_account_email_user(@email, @account_name, @pull_request_url)
  end

  test 'should log a warning and return nil if NOTIFY_API_KEY is not set for user email method' do
    # Have to re-initialise the class to remove NOTIFY_API_KEY ENV var
    reset_env_vars()
    @notify_service = NotifyService.new

    Rails.logger.expects(:warn).with('Warning: no NOTIFY_API_KEY set. Skipping emails.')

    result = @notify_service.new_account_email_user(@email, @account_name, @pull_request_url)
    assert_nil result
  end
end