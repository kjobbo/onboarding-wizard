require "test_helper"

class Onboardings::SummariesControllerTest < ActionDispatch::IntegrationTest
  def sign_up
    post onboarding_path
    Onboarding.find_by!(token: session[:onboarding_token])
  end

  def complete_all_steps!(onboarding)
    onboarding.create_personal_details!(first_name: "Joe", last_name: "Bloggs",
                                        email: "joe@example.com", completed_at: Time.current)
    onboarding.create_address!(address_line_1: "1 High Street", city: "London",
                               postcode: "SW1A 1AA", country: "United Kingdom",
                               completed_at: Time.current)
    onboarding.create_preferences!(plan: "standard", billing_period: "monthly",
                                   newsletter_opt_in: true, completed_at: Time.current)
    onboarding.update!(current_step: "summary")
  end

  test "redirects to the landing page without a session" do
    get onboarding_summary_path

    assert_redirected_to root_path
  end

  test "redirects to the first incomplete step when not ready" do
    onboarding = sign_up

    get onboarding_summary_path
    assert_redirected_to onboarding_personal_details_path

    onboarding.create_personal_details!(first_name: "Joe", last_name: "Bloggs",
                                        email: "joe@example.com", completed_at: Time.current)

    get onboarding_summary_path
    assert_redirected_to onboarding_address_path
  end

  test "shows everything entered, with edit links and a confirm button" do
    complete_all_steps!(sign_up)

    get onboarding_summary_path

    assert_response :success
    assert_select "body", text: /Joe Bloggs/
    assert_select "body", text: /joe@example\.com/
    assert_select "body", text: /1 High Street/
    assert_select "body", text: /SW1A 1AA/
    assert_select "body", text: /Standard/
    assert_select "body", text: /Monthly/

    assert_select "a[href=?]", onboarding_personal_details_path
    assert_select "a[href=?]", onboarding_address_path
    assert_select "a[href=?]", onboarding_preferences_path
    assert_select "form[action=?]", onboarding_completion_path
  end

  test "completing the onboarding stamps it and shows the done state" do
    onboarding = sign_up
    complete_all_steps!(onboarding)

    post onboarding_completion_path

    assert_redirected_to onboarding_summary_path
    assert_predicate onboarding.reload, :completed?

    follow_redirect!
    assert_response :success
    assert_select "form[action=?]", onboarding_completion_path, count: 0
  end

  test "completion refuses while steps are incomplete" do
    onboarding = sign_up

    post onboarding_completion_path

    assert_not onboarding.reload.completed?
    assert_redirected_to onboarding_summary_path
    follow_redirect!
    assert_redirected_to onboarding_personal_details_path
  end
end
