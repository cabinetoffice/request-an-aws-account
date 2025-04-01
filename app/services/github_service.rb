require 'octokit'

class GithubService
  def initialize
    if ENV.has_key? 'GITHUB_PERSONAL_ACCESS_TOKEN'
      @client = Octokit::Client.new(access_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])
    end
  end

  def create_new_account_pull_request(account_name, account_description, email, admin_users, tags, host)
    unless @client
      Errors::log_error 'No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    new_branch_name = 'new-aws-account-' + account_name
    github_repo = 'cabinetoffice/cope-aws-account-billing-test'
    master = @client.commit(github_repo, 'master')
    create_branch github_repo, new_branch_name, master.sha

    for accounts_path in ['terraform/accounts.tf.json', 'terraform/accounts.tf'] do
      begin
        accounts_contents = @client.contents github_repo, path: accounts_path
      rescue Octokit::NotFound
        # allow a final failure to be detected
        accounts_path = nil
      else
        break
      end
    end
    unless accounts_path
      Errors::log_error "Couldn't locate accounts terraform file."
      return nil
    end

    name = email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    terraform_accounts_service = TerraformAccountsService.new(Base64.decode64(accounts_contents.content))
    new_account_terraform = terraform_accounts_service.add_account(account_name, tags)
    account_description_quote = account_description.split(/\r?\n/).map {|desc| "> #{desc}"}.join("\n")
    @client.update_contents(
      github_repo,
      accounts_path,
      # TODO add cost center an org in here.
      "Add new AWS account for: #{account_name} 

Description:
#{account_description_quote}

Co-authored-by: #{name} <#{email}>",
      accounts_contents.sha,
      new_account_terraform,
      branch: new_branch_name
    )
    @client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      # TODO add org and const centre in this string
      "Add new AWS account for: #{account_name}",
      "Account requested using #{host} by #{email}

Description:
#{account_description_quote}

Once the account is created, the following users should be granted access to the admin role:

```
#{admin_users}
```"
    ).html_url
  end

  private

  def create_branch(repo, branch_name, sha)
    begin
      @client.create_ref repo, 'heads/' + branch_name, sha
    rescue Octokit::UnprocessableEntity => e
      Errors::log_error "Failed to create branch #{branch_name}. Perhaps there's already a branch with that name?", e
    end
  end

  def multiple_users?(email_list)
    email_list.split('@').size > 2
  end
end
