require "test_helper"

class Onboardings::PreferencesControllerTest < ActionDispatch::IntegrationTest
  def valid_params(attributes = {})
    {
      preferences: {
        plan: "standard",
        billing_period: "monthly",
        newsletter_opt_in: "1"
      }.merge(attributes)
    }
  end

  def sign_up
    post onboarding_path
    Onboarding.find_by!(token: session[:onboarding_token])
  end

  test "redirects to the landing page without a session" do
    get onboarding_preferences_path

    assert_redirected_to root_path
  end

  test "a valid submission saves the step, marks it completed and advances" do
    onboarding = sign_up

    patch onboarding_preferences_path, params: valid_params

    assert_redirected_to onboarding_path
    assert_response :see_other

    preferences = onboarding.reload.preferences
    assert_equal "standard", preferences.plan
    assert_equal "monthly", preferences.billing_period
    assert preferences.newsletter_opt_in
    assert_predicate preferences, :completed?
    assert_equal "summary", onboarding.current_step
  end

  test "an invalid submission re-renders the form with errors and saves nothing" do
    onboarding = sign_up

    patch onboarding_preferences_path,
          params: valid_params(plan: "", billing_period: "")

    assert_response :unprocessable_entity
    assert_select "form" do
      assert_select "p", text: /must be one of the available plans/
      assert_select "p", text: /must be monthly or annual/
    end
    assert_nil onboarding.reload.preferences
    assert_equal "personal_details", onboarding.current_step
  end

  test "resubmitting edits the same record without moving completed_at" do
    onboarding = sign_up
    patch onboarding_preferences_path, params: valid_params
    completed_at = onboarding.reload.preferences.completed_at

    travel 1.hour do
      assert_no_difference "Onboardings::Preferences.count" do
        patch onboarding_preferences_path, params: valid_params(plan: "pro")
      end
    end

    preferences = onboarding.reload.preferences
    assert_equal "pro", preferences.plan
    assert_equal completed_at, preferences.completed_at
  end

  test "revisiting the form shows the saved selections" do
    sign_up
    patch onboarding_preferences_path, params: valid_params

    get onboarding_preferences_path

    assert_response :success
    assert_select "input[type=radio][name=?][value=?][checked]", "preferences[plan]", "standard"
    assert_select "input[type=radio][name=?][value=?][checked]", "preferences[billing_period]", "monthly"
    assert_select "input[type=checkbox][name=?][checked]", "preferences[newsletter_opt_in]"
  end
end
