require 'test_helper'

class OrganisationControllerTest < ActionDispatch::IntegrationTest
  setup {
    sign_in 'test@example.com'
    set_session(
      'test@example.com',
      'account_name' => "good-account-name"
    )
  }

  test 'should get index' do
    get organisation_url
    assert_response :success
  end

  test 'should validate empty form' do
    post organisation_url, params: { organisation_form: { organisation: nil } }
    assert_response :success
    assert_select '.govuk-error-message', 'Billing information is required'
  end

  test 'should error if cost centre code is not entered when Cabinet Office selected' do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office"} }
    assert_select '.govuk-error-message', 'Enter a cost centre'
  end

  test 'should error if cost centre code is not found in reader' do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office", cost_centre_code: "99999"} }
    assert_select '.govuk-error-message', 'Cost centre code not found'
  end

  test 'should save cost centre data to session'  do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office", cost_centre_code: "12345678"} }
    
    session_form = session[:form]
    assert_equal session_form[:organisation], "Cabinet Office"
    assert_equal session_form[:cost_centre_code], "12345678"
    assert_equal session_form[:cost_centre_description], "BOOM"
    assert_equal session_form[:business_unit], "BING"
    assert_equal session_form[:subsection], "BAZ"
  end
  
  test 'should not save cost centre data to session if org isnt cabinet office'  do
    post organisation_url, params: { organisation_form: { organisation: "Government Property Agency", cost_centre_code: ""} }
    
    session_form = session[:form]
    assert_equal session_form[:organisation], "Government Property Agency"
    assert_nil session_form[:cost_centre_code]
    assert_nil session_form[:cost_centre_description]
    assert_nil session_form[:business_unit]
    assert_nil session_form[:subsection]    
  end 
  
  test 'should redirect to org summaary if org is cabinet office'  do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office", cost_centre_code: "12345678"} }
    assert_redirected_to organisation_summary_url
  end
  
  test 'should redirect to team path if org is not cabinet office'  do
    post organisation_url, params: { organisation_form: { organisation: "Government Property Agency", cost_centre_code: ""} }
    assert_redirected_to team_url
  end 
end
