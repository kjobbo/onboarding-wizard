require "test_helper"

class Onboardings::AddressesControllerTest < ActionDispatch::IntegrationTest
  def valid_params(attributes = {})
    {
      address: {
        address_line_1: "1 High Street",
        address_line_2: "Flat 2",
        city: "London",
        postcode: "SW1A 1AA",
        country: "United Kingdom"
      }.merge(attributes)
    }
  end

  def sign_up
    post onboarding_path
    Onboarding.find_by!(token: session[:onboarding_token])
  end

  test "redirects to the landing page without a session" do
    get onboarding_address_path

    assert_redirected_to root_path
  end

  test "shows the address form with a back link to personal details" do
    sign_up
    get onboarding_address_path

    assert_response :success
    assert_select "form[action=?]", onboarding_address_path do
      %w[address_line_1 address_line_2 city postcode country].each do |field|
        assert_select "input[name=?]", "address[#{field}]"
      end
    end
    assert_select "a[href=?]", onboarding_personal_details_path
  end

  test "a valid submission saves the step, marks it completed and advances" do
    onboarding = sign_up

    patch onboarding_address_path, params: valid_params

    assert_redirected_to onboarding_path
    assert_response :see_other

    address = onboarding.reload.address
    assert_equal [ "1 High Street", "Flat 2", "London", "SW1A 1AA", "United Kingdom" ],
                 address.lines
    assert_predicate address, :completed?
    assert_equal "preferences", onboarding.current_step
  end

  test "an invalid submission re-renders the form with errors and saves nothing" do
    onboarding = sign_up

    patch onboarding_address_path,
          params: valid_params(address_line_1: "", city: "", postcode: "", country: "")

    assert_response :unprocessable_entity
    assert_select "form" do
      assert_select "p", text: /can't be blank/, minimum: 1
    end
    assert_nil onboarding.reload.address
    assert_equal "personal_details", onboarding.current_step
  end

  test "resubmitting edits the same record without moving completed_at" do
    onboarding = sign_up
    patch onboarding_address_path, params: valid_params
    completed_at = onboarding.reload.address.completed_at

    travel 1.hour do
      assert_no_difference "Onboardings::Address.count" do
        patch onboarding_address_path, params: valid_params(city: "Leeds")
      end
    end

    address = onboarding.reload.address
    assert_equal "Leeds", address.city
    assert_equal completed_at, address.completed_at
  end

  test "revisiting the form shows the saved values" do
    sign_up
    patch onboarding_address_path, params: valid_params

    get onboarding_address_path

    assert_response :success
    assert_select "input[name=?][value=?]", "address[address_line_1]", "1 High Street"
    assert_select "input[name=?][value=?]", "address[postcode]", "SW1A 1AA"
  end
end
