class ConfirmationController < ApplicationController
  def account
    @pull_request_url = session.fetch('pull_request_url', 'ERROR')
    session['form'] = nil
  end
end
