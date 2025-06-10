ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

class ActiveSupport::TestCase

  def set_stub_env_vars
    ENV['GITHUB_PERSONAL_ACCESS_TOKEN'] = 'SOME_GITHUB_ACCESS_TOKEN'
    ENV['NOTIFY_API_KEY'] = 'some_notify_access_token0-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000'
  end

  def reset_env_vars
    ENV.delete('GITHUB_PERSONAL_ACCESS_TOKEN')
    ENV.delete('NOTIFY_API_KEY')
  end

  def sign_in(email)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email }) }
    follow_redirect!
  end

  def set_session(email, form)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email, 'form' => form }) }
    follow_redirect!
  end

  def read_from_session(key)
    get "#{::RackSessionAccess.path}.raw"
    session = RackSessionAccess.decode(html_document.css("pre").inner_html)
    session[key]
  end

  def stub_notify_emails
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email").
      to_return(status: 200, body: '{}', headers: {})
  end

  def assert_notify_emails_sent
    bodies = []
    assert_requested(:post, "https://api.notifications.service.gov.uk/v2/notifications/email", at_least_times: 1) do |req|
      bodies.push(req.body)
      true
    end
    assert_not_empty bodies
    return assert_nothing_raised { bodies.map{|b|JSON.parse(b)} }
  end

  def assert_content_updated(repository_api, path)
    body = nil
    assert_requested(:put, "#{repository_api}/contents#{path}") do |req|
      body = req.body
      true
    end
    assert_not_nil body
    body_json = assert_nothing_raised { JSON.parse(body) }
    assert_not_nil body_json["content"]
    content_decoded = assert_nothing_raised { Base64.decode64(body_json["content"]) }
    return assert_nothing_raised { JSON.parse(content_decoded) }
  end

  def build_content_request(input)
    JSON.dump(content: Base64.encode64(JSON.dump(input)))
  end
end
