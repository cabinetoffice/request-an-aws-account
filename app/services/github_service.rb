require 'octokit'

class GithubService
    MAIN_BRANCH = 'main'
    
  def initialize
    if ENV.has_key? 'GITHUB_PERSONAL_ACCESS_TOKEN'
      @client = Octokit::Client.new(access_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])
    end
    @github_repo = ENV.fetch('GITHUB_REPO') { raise "Missing required environment variable: GITHUB_REPO" }
  end

  def create_new_account_pull_request(account_name, account_description, email, admin_users, account_terraform_file, host)
    unless @client
      Errors::log_error 'No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    new_branch_name = "new-aws-account-#{account_name}"
    latest_commit_on_main = @client.commit(@github_repo, MAIN_BRANCH)
    new_file_filepath = "terraform/#{account_name}.tf"
    pull_request_title = "Add new AWS account for: #{account_name}"
    account_description_quote = format_account_description(account_description)
    commit_message = create_commit_message(account_name, account_description_quote, email)
    pull_request_body = create_pull_request_body(account_name, account_description_quote, email, admin_users)

    # check if account terraform file already exists on main branch
    check_if_file_already_exists(@github_repo, MAIN_BRANCH, new_file_filepath)

    # create branch for new aws account 
    create_new_aws_account_branch(@github_repo, new_branch_name, latest_commit_on_main.sha)

    # create the aws account terraform file on new branch
    @client.create_contents(@github_repo, new_file_filepath, commit_message, account_terraform_file, branch: new_branch_name)

    # raise the PR
    return @client.create_pull_request(@github_repo, MAIN_BRANCH, new_branch_name, pull_request_title, pull_request_body).html_url
  end

  def format_account_description(account_description)
    return account_description.split(/\r?\n/).map {|desc| "> #{desc}"}.join("\n")
  end

  def create_commit_message(account_name, account_description_quote, email)
    name = email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')

    ###
    commit_message = <<~TEXT
    Add new AWS account for: #{account_name} 

    Description:
    #{account_description_quote}

    Co-authored-by: #{name} <#{email}>"
    TEXT
    ###

    return commit_message
  end

  def create_pull_request_body(host, account_description_quote, email, admin_users)
    ###
    pull_request_body = <<~TEXT 
    Account requested using #{host} by #{email}

    Description:
    #{account_description_quote}

    Once the account is created, the following users should be granted access to the admin role:

    ```
    #{admin_users}
    ```
    TEXT
    ###

    return pull_request_body
  end

  def check_if_file_already_exists(repo, branch_name, filepath)
    # raise error if the new file being created already exists
    if @client.contents(repo, path: filepath, ref: branch_name)
      raise Errors::AccountTerraformFileAlreadyExistsError, filepath
    end
  rescue Octokit::NotFound
    Rails.logger.info("Creating account Terraform file as it does not exist")
  end

  def create_new_aws_account_branch(repo, branch_name, sha)
    begin
      @client.create_ref repo, 'heads/' + branch_name, sha
    rescue Octokit::UnprocessableEntity => e
      Errors::log_error "Failed to create branch #{branch_name}. Perhaps there's already a branch with that name?", e
    end
  end
end
