require 'notifications/client'

class NotifyService
  def initialize
    @notify_api_key = ENV['NOTIFY_API_KEY']
  end

  def new_account_email_support(personalisation)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'co-aws-requests@cabinetoffice.gov.uk',
      template_id: '25c1f81c-bcd4-46eb-bc9d-5874504c4464',
      personalisation: personalisation
    )
  end

  def new_account_email_user(email, account_name, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: email,
      template_id: '6e05fe05-5a6e-411e-85e0-b4e4d8dc494f',
      personalisation: {
        account_name: account_name,
        pull_request_url: pull_request_url
      }
    )
  end
end
