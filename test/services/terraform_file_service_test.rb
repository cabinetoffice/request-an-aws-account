require 'test_helper'
require 'mocks/form_params'
require 'mocks/tags'
require 'mocks/alternate_contacts'

class TerraformFileServiceTest < ActiveSupport::TestCase
  ORGANISATION_UNIT = "Workloads ou-mcdg-wg49h2bw"

  def setup
    @terraform_file_service = TerraformFileService.new
    @fake_emails = ["fake@email.com", "fake2@email.com"]
  end

  test 'creates a terraform file with the correct content' do

    form_params = FormParams.out_of_hours_support_true
    tags = Tags.tags_containing_out_of_hours_support
    alternate_contacts = AlternateContacts.alternate_contacts
    admin_users = <<-ADMIN_USERS
    admin_users = jsonencode(#{@fake_emails})
    ADMIN_USERS

    # stubbing all the class methods 
    @terraform_file_service.stubs(:generate_tags).returns(tags)
    @terraform_file_service.stubs(:generate_alternate_contact).returns(alternate_contacts)
    @terraform_file_service.stubs(:generate_admin_users).returns(admin_users)

    expected_terraform_file = <<~TF
      module "#{form_params['account_name']}" {
        source = "./modules/aft-account-request"
      
        control_tower_parameters = {
          AccountEmail = "aws-root+#{form_params['account_name']}@cabinetoffice.gov.uk"
          AccountName  = "#{form_params['account_name']}"
      
          # Syntax for top-level OU
          ManagedOrganizationalUnit = "#{ORGANISATION_UNIT}"
          # Syntax for nested OU
          # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
      
          SSOUserEmail     = "null"
          SSOUserFirstName = "null"
          SSOUserLastName  = "null"
        }
      
        account_tags = {
      #{tags}  }
      
        change_management_parameters = {
          change_requested_by = "#{@fake_emails[0]}"
          change_reason       = ""
        }

        custom_fields = {
      #{alternate_contacts}
      #{admin_users}  }

        account_customizations_name = "#{form_params['account_name']}"
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

  test 'should generate alternate contacts information' do

    expected_alternate_contacts = AlternateContacts.alternate_contacts

    alternate_contacts = @terraform_file_service.generate_alternate_contacts()

    assert_equal expected_alternate_contacts, alternate_contacts
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