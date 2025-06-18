class TerraformAccountsService
  AWS_ROOT_ACCOUNTS_EMAIL_FORMAT = 'aws-root+%s@cabinetoffice.gov.uk'

  def initialize users_terraform
    @users_terraform_orig = JSON.parse users_terraform
    @users_terraform = JSON.parse users_terraform
  end

  def add_account(account_name, tags)
    accounts = @users_terraform.fetch 'resource'
    resource_names = accounts.map {|u| u['aws_organizations_account'].keys }.flatten

    if resource_names.include? account_name
      raise Errors::AccountAlreadyExistsError.new account_name
    end

    tags.each {| name, value |
    new_value = value
      new_value = new_value.gsub("&", "AND")
      new_value = new_value.gsub(/[^ A-Za-z0-9.:+=@_\/\-]/, '')
      tags[name] = new_value
    }
    accounts.push('aws_organizations_account' => {
      account_name => {
        'name': account_name,
        'email': AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % account_name,
        'role_name': 'bootstrap',
        'iam_user_access_to_billing': 'ALLOW',
        'tags': tags
      }
    })

    accounts.sort_by! { |u| u['aws_organizations_account'].keys.first }

    JSON.pretty_generate(@users_terraform) + "\n"
  end

end
