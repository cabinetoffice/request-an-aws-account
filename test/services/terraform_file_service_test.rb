require 'test_helper'
require 'mocks/form_params'
require 'mocks/tags'

class TerraformFileServiceTest < ActiveSupport::TestCase

  SSO_PLACEHOLDER_VALUE = 'null'
  AWS_ROOT_ACCOUNTS_EMAIL_FORMAT = 'aws-root+%s@cabinetoffice.gov.uk'

  def setup
    set_stub_env_vars()
    @terraform_file_service = TerraformFileService.new
    @aws_root_accounts_email_format = ENV['AWS_ROOT_ACCOUNTS_EMAIL_FORMAT']
    @organisation_unit = ENV['ORGANISATION_UNIT']
    @sso_user_email = ENV['SSO_USER_EMAIL']
    @fake_emails = ["fake@email.com", "fake2@email.com"]
  end

  def teardown
    reset_env_vars()
  end

  test 'should raise error if ORGANISATION_UNIT is not set' do

    ENV.delete('ORGANISATION_UNIT')

    begin
      form_params = FormParams.out_of_hours_support_true
      @terraform_file_service = TerraformFileService.new
      @terraform_file_service.create_account_terraform_file(form_params, @fake_emails[0])
      flunk('Expected RuntimeError was not raised')
    rescue RuntimeError => e
      assert_match(/Missing required environment variable: ORGANISATION_UNIT/, e.message)
    end
  end

  test 'should raise error if SSO_USER_EMAIL is not set' do

    ENV.delete('SSO_USER_EMAIL')

    begin
      form_params = FormParams.out_of_hours_support_true
      @terraform_file_service = TerraformFileService.new
      @terraform_file_service.create_account_terraform_file(form_params, @fake_emails[0])
      flunk('Expected RuntimeError was not raised')
    rescue RuntimeError => e
      assert_match(/Missing required environment variable: SSO_USER_EMAIL/, e.message)
    end
  end


  test 'creates a terraform file with the correct content' do

    form_params = FormParams.out_of_hours_support_true
    account_name = form_params['account_name']
    tags = Tags.tags_containing_out_of_hours_support
    admin_users = <<-ADMIN_USERS
    admin_users = jsonencode(#{@fake_emails})
    ADMIN_USERS

    # stubbing all the class methods 
    @terraform_file_service.stubs(:generate_tags).returns(tags)
    @terraform_file_service.stubs(:generate_admin_users).returns(admin_users)

    expected_terraform_file = <<~TF
    module "#{account_name}" {
      source = "./modules/aft-account-request"
    
      control_tower_parameters = {
        AccountEmail = "#{AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % account_name}"
        AccountName  = "#{account_name}"
    
        # Syntax for top-level OU
        ManagedOrganizationalUnit = "#{@organisation_unit}"
        # Syntax for nested OU
        # ManagedOrganizationalUnit = "Sandbox (ou-xxx5-x8xx8xx8)"
    
        SSOUserEmail     = "#{@sso_user_email}"
        SSOUserFirstName = SSO_PLACEHOLDER_VALUE
        SSOUserLastName  = SSO_PLACEHOLDER_VALUE
      }
    
      account_tags = {
    #{tags}  }
    
      change_management_parameters = {
        change_requested_by = "#{@fake_emails[0]}"
        change_reason       = ""
      }

      custom_fields = {
    #{admin_users}  }

      account_customizations_name = "#{account_name}"
    }
  TF

    terraform_file = @terraform_file_service.create_account_terraform_file(form_params, @fake_emails[0])

    assert_equal expected_terraform_file, terraform_file
  end

  test 'should add out of hours tags if out of hours support tag is true' do
    form_params = FormParams.out_of_hours_support_true
    expected_tags = Tags.tags_containing_out_of_hours_support

    tags = @terraform_file_service.generate_tags(form_params)

    assert_equal expected_tags, tags
  end

  test 'should omit out of hours from tags if out of hours support tag is false' do
    form_params = FormParams.out_of_hours_support_false
    expected_tags = Tags.tags_without_out_of_hours_support

    tags = @terraform_file_service.generate_tags(form_params)

    assert_equal expected_tags, tags
  end

  test 'should remove fields with nil values from tags' do
    form_params = FormParams.with_nil_value
    expected_tags = Tags.tags_containing_out_of_hours_support

    tags = @terraform_file_service.generate_tags(form_params)

    assert_equal expected_tags, tags
    refute_includes tags, 'empty_field'
  end

  test 'should generate admin users' do

    fake_emails_param = FormParams.out_of_hours_support_false['admin_users']

    expected_admins = <<-ADMIN_USERS
    admin_users = jsonencode(#{@fake_emails})
    ADMIN_USERS

    admins = @terraform_file_service.generate_admin_users(fake_emails_param)

    assert_equal expected_admins, admins
  end

  test 'should sanitise admin users by removing carriage return and newline special characters' do

    fake_emails_param_with_special_chars = "\r\n\r\n#{@fake_emails[0]}\r\n\r\n\r\n#{@fake_emails[1]}\r\n\r\n"

    expected_admins = <<-ADMIN_USERS
    admin_users = jsonencode(#{@fake_emails})
    ADMIN_USERS

    admins = @terraform_file_service.generate_admin_users(fake_emails_param_with_special_chars)

    assert_equal expected_admins, admins
  end
end