require "test_helper"

class OnboardingsControllerTest < ActionDispatch::IntegrationTest
  test "landing page shows a sign-up form posting to the onboarding path" do
    get root_path

    assert_response :success
    assert_select "form[action=?][method=?]", onboarding_path, "post" do
      assert_select "button", text: /sign up/i
    end
  end

  test "signing up creates an onboarding and redirects into the wizard" do
    assert_difference "Onboarding.count", 1 do
      post onboarding_path
    end

    assert_redirected_to onboarding_path
  end

  test "signing up again resumes the existing onboarding instead of creating another" do
    post onboarding_path
    existing = Onboarding.last

    assert_no_difference "Onboarding.count" do
      post onboarding_path
    end

    assert_redirected_to onboarding_path
    follow_redirect!
    assert_equal existing, Onboarding.find_by(token: session[:onboarding_token])
  end

  test "after signing up the visitor is routed to their current step" do
    post onboarding_path
    follow_redirect!

    assert_redirected_to onboarding_personal_details_path
    follow_redirect!
    assert_response :success
    assert_select "form[action=?]", onboarding_personal_details_path
  end

  test "signing up with a stale token creates a fresh onboarding with a new token" do
    post onboarding_path
    stale_token = session[:onboarding_token]
    Onboarding.last.destroy!

    assert_difference "Onboarding.count", 1 do
      post onboarding_path
    end

    assert_not_equal stale_token, session[:onboarding_token]
  end

  test "visiting the wizard without a session redirects to the landing page" do
    get onboarding_path

    assert_redirected_to root_path
  end

  test "visiting the wizard with a stale token redirects to the landing page" do
    post onboarding_path
    Onboarding.last.destroy!

    get onboarding_path

    assert_redirected_to root_path
  end
end
