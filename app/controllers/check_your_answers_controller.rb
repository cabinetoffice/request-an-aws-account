class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
    @form = AccountDetailsForm.new(session.fetch('form', {}))
  end

  def post
    @form = AccountDetailsForm.new(session.fetch('form', {}))
    @answers = session.fetch('form', {}).with_indifferent_access

    form_params = session['form']
    email = session['email']
    account_name = form_params['account_name']
    account_description = form_params['account_description']
    admin_users = form_params['admin_users']

    begin

      account_terraform_file = TerraformFileService.new.create_account_terraform_file(form_params, email)

      pull_request_url = GithubService.new.create_new_account_pull_request(
        account_name,
        account_description,
        email,
        admin_users,
        account_terraform_file,
        request.host
      )

      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.new_account_email_co_aws_requests_google_group({
        account_name: account_name,
        account_description: account_description,
        email: email,
        pull_request_url: pull_request_url,
        admin_users: admin_users
      })
      notify_service.new_account_email_user(email, account_name, pull_request_url)

      redirect_to confirmation_account_path
    rescue Errors::AccountTerraformFileAlreadyExistsError => e
      @form.errors.add 'account_name', "error. An AWS account with this name already exists in the organisation, you cannot choose a duplicated name. Please change the name of the AWS account."
      Errors::log_error 'Account Terraform file already existed', e
      return render :check_your_answers
    rescue StandardError => e
      @form.errors.add 'commit', 'unknown error when opening pull request or sending email'
      Errors::log_error 'Failed to raise account creation PR or send email', e
      return render :check_your_answers
    end
  end
end
