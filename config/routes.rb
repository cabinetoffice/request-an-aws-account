Rails.application.routes.draw do
  get '/', to: 'index#index', as: :index
  post '/', to: 'index#post'

  get '/account-details', to: 'account_details#account_details', as: :account_details
  post '/account-details', to: 'account_details#post'

  get '/organisation', to: 'organisation#organisation', as: :organisation
  post '/organisation', to: 'organisation#post'
  
  get '/organisation_summary', to: 'organisation_summary#organisation_summary', as: :organisation_summary
  post '/organisation_summary', to: 'organisation_summary#post'

  get '/team', to: 'team#team', as: :team
  post '/team', to: 'team#post'

  get '/service', to: 'service#service', as: :service
  post '/service', to: 'service#post'

  get '/out-of-hours-support', to: 'out_of_hours_support#out_of_hours_support', as: :out_of_hours_support
  post '/out-of-hours-support', to: 'out_of_hours_support#post'

  get '/security', to: 'security#security', as: :security
  post '/security', to: 'security#post'

  get '/administrators', to: 'administrators#administrators', as: :administrators
  post '/administrators', to: 'administrators#post'

  get '/check-your-answers', to: 'check_your_answers#check_your_answers', as: :check_your_answers
  post '/check-your-answers', to: 'check_your_answers#post'

  get '/confirmation/account', to: 'confirmation#account', as: :confirmation_account

  get '/auth/google_oauth2/callback', to: 'google_auth#callback'
  get '/auth/google_oauth2/error/bad-email', to: 'google_auth#error_bad_email', as: :error_bad_email

  if Rails.env.development?
    get '/dev-login' => 'development#dev_login'
  end
end
