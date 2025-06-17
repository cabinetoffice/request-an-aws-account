require 'test_helper'
require 'octokit'

class GithubServiceTest < ActiveSupport::TestCase
  def setup
    set_stub_env_vars()
    @github_service = GithubService.new
    @branch_name = 'test-branch'
    @filepath = 'terraform/test-file.tf'
    @account_name = 'test-account'
    @account_description = "This is a test account.\nIt is used for testing."
    @email = 'test.user@example.com'
    @admin_users = 'test.user'
    @account_terraform_file = 'terraform content'
    @host = 'http://example.com'
    @new_branch_name = "new-aws-account-#{@account_name}"
    @commit_message = "Add new AWS account for: #{@account_name}"
    @pull_request_title = "Add new AWS account for: #{@account_name}"
    @pull_request_body = "Account requested using #{@host} by #{@account_name}"
    @latest_commit_sha = 'abc123'

    Octokit::Client.any_instance.stubs(:commit).returns(stub(sha: @latest_commit_sha))
    Octokit::Client.any_instance.stubs(:create_ref)
    Octokit::Client.any_instance.stubs(:create_contents)
    Octokit::Client.any_instance.stubs(:create_pull_request).returns(stub(html_url: 'http://example.com/pr'))
    Octokit::Client.any_instance.stubs(:contents).raises(Octokit::NotFound)
  end

  def teardown
    reset_env_vars()
  end

  test 'should create new account pull request' do
    result = @github_service.create_new_account_pull_request(@account_name, @account_description, @email, @admin_users, @account_terraform_file, @host)
    assert_equal 'http://example.com/pr', result
  end

  test 'should return nil if GITHUB_PERSONAL_ACCESS_TOKEN is not set' do

    ENV.delete('GITHUB_PERSONAL_ACCESS_TOKEN')

    @github_service = GithubService.new

    result = @github_service.create_new_account_pull_request(@account_name, @account_description, @email, @admin_users, @account_terraform_file, @host)
    assert_nil result
  end

  test 'should raise error if GITHUB_REPO is not set' do

    ENV.delete('GITHUB_REPO')

    begin
      @github_service = GithubService.new
      @github_service.create_new_account_pull_request(@account_name, @account_description, @email, @admin_users, @account_terraform_file, @host)
      flunk('Expected RuntimeError was not raised')
    rescue RuntimeError => e
      assert_match(/Missing required environment variable: GITHUB_REPO/, e.message)
    end
  end

  test 'should format account description correctly' do
    formatted_description = @github_service.send(:format_account_description, @account_description)

    assert_equal "> This is a test account.\n> It is used for testing.", formatted_description
  end

  test 'should create commit message in correct format' do
    commit_message = @github_service.send(:create_commit_message, @account_name, "> This is a test account.\n> It is used for testing.", @email)

    assert_includes commit_message, "Add new AWS account for: #{@account_name}"
    assert_includes commit_message, "Description:\n> This is a test account.\n> It is used for testing."
    assert_includes commit_message, "Co-authored-by: Test User <#{@email}>"
  end

  test 'should create pull request body in correct format' do
    pull_request_body = @github_service.send(:create_pull_request_body, @host, "> This is a test account.\n> It is used for testing.", @email, @admin_users)

    assert_includes pull_request_body, "Account requested using #{@host} by #{@email}"
    assert_includes pull_request_body, "Description:\n> This is a test account.\n> It is used for testing."
    assert_includes pull_request_body, "```\n#{@admin_users}\n```"
  end

  test 'should log if terraform file does not exist and create it' do
    Octokit::Client.any_instance.stubs(:contents).raises(Octokit::NotFound)
    Rails.logger.expects(:info).with("Creating account Terraform file as it does not exist")

    @github_service.check_if_file_already_exists(@repo, @branch_name, @filepath)
  end

  test 'should raise error if terraform file already exists' do
    Octokit::Client.any_instance.stubs(:contents).returns(stub)

    assert_raises(Errors::AccountTerraformFileAlreadyExistsError) do
      @github_service.check_if_file_already_exists(@repo, @branch_name, @filepath)
    end
  end

  test 'should create a new branch for the new aws account' do
    Octokit::Client.any_instance.expects(:create_ref).with(@repo, 'heads/' + @branch_name, @sha)

    @github_service.create_new_aws_account_branch(@repo, @branch_name, @sha)
  end

  test 'should log an error if branch creation fails' do
    Octokit::Client.any_instance.stubs(:create_ref).raises(Octokit::UnprocessableEntity)
    Errors.expects(:log_error).with("Failed to create branch #{@branch_name}. Perhaps there's already a branch with that name?", instance_of(Octokit::UnprocessableEntity))

    @github_service.create_new_aws_account_branch(@repo, @branch_name, @sha)
  end
end
