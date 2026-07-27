require "test_helper"

class Onboardings::PersonalDetailsControllerTest < ActionDispatch::IntegrationTest
  def valid_params(attributes = {})
    {
      personal_details: {
        first_name: "Joe",
        last_name: "Bloggs",
        email: "joe@example.com"
      }.merge(attributes)
    }
  end

  def sign_up
    post onboarding_path
    Onboarding.find_by!(token: session[:onboarding_token])
  end

  test "redirects to the landing page without a session" do
    get onboarding_personal_details_path

    assert_redirected_to root_path
  end

  test "shows the personal details form" do
    sign_up
    get onboarding_personal_details_path

    assert_response :success
    assert_select "form[action=?]", onboarding_personal_details_path do
      assert_select "input[name=?]", "personal_details[first_name]"
      assert_select "input[name=?]", "personal_details[last_name]"
      assert_select "input[name=?]", "personal_details[email]"
    end
  end

  test "a valid submission saves the step, marks it completed and advances" do
    onboarding = sign_up

    patch onboarding_personal_details_path, params: valid_params

    assert_redirected_to onboarding_path
    assert_response :see_other

    details = onboarding.reload.personal_details
    assert_equal "Joe Bloggs", details.full_name
    assert_predicate details, :completed?
    assert_equal "address", onboarding.current_step
  end

  test "an invalid submission re-renders the form with errors and saves nothing" do
    onboarding = sign_up

    patch onboarding_personal_details_path,
          params: { personal_details: { first_name: "", last_name: "", email: "not-an-email" } }

    assert_response :unprocessable_entity
    assert_select "form" do
      assert_select "p", text: /can't be blank/, minimum: 1
      assert_select "p", text: /must be a valid email address/
    end
    assert_nil onboarding.reload.personal_details
    assert_equal "personal_details", onboarding.current_step
  end

  test "resubmitting edits the same record without moving completed_at" do
    onboarding = sign_up
    patch onboarding_personal_details_path, params: valid_params
    completed_at = onboarding.reload.personal_details.completed_at

    travel 1.hour do
      assert_no_difference "Onboardings::PersonalDetails.count" do
        patch onboarding_personal_details_path, params: valid_params(first_name: "Joseph")
      end
    end

    details = onboarding.reload.personal_details
    assert_equal "Joseph", details.first_name
    assert_equal completed_at, details.completed_at
  end

  test "revisiting the form shows the saved values" do
    sign_up
    patch onboarding_personal_details_path, params: valid_params

    get onboarding_personal_details_path

    assert_response :success
    assert_select "input[name=?][value=?]", "personal_details[first_name]", "Joe"
    assert_select "input[name=?][value=?]", "personal_details[email]", "joe@example.com"
  end
end
