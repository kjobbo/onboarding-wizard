require "test_helper"

class OnboardingTest < ActiveSupport::TestCase
  setup do
    @onboarding = Onboarding.create!
  end

  def complete_personal_details!
    @onboarding.create_personal_details!(first_name: "Joe", last_name: "Bloggs",
                                         email: "joe@example.com", completed_at: Time.current)
  end

  def complete_address!
    @onboarding.create_address!(address_line_1: "1 High Street", city: "London",
                                postcode: "SW1A 1AA", country: "United Kingdom",
                                completed_at: Time.current)
  end

  def complete_preferences!
    @onboarding.create_preferences!(plan: "standard", billing_period: "monthly",
                                    completed_at: Time.current)
  end

  test "generates a token on create" do
    onboarding = Onboarding.create!

    assert onboarding.token.present?
  end

  test "first_incomplete_step walks the form steps in order" do
    assert_equal "personal_details", @onboarding.first_incomplete_step

    complete_personal_details!
    assert_equal "address", @onboarding.first_incomplete_step

    complete_address!
    assert_equal "preferences", @onboarding.first_incomplete_step

    complete_preferences!
    assert_nil @onboarding.first_incomplete_step
  end

  test "a step that exists but is not completed still counts as incomplete" do
    @onboarding.create_personal_details!(first_name: "Joe", last_name: "Bloggs",
                                         email: "joe@example.com")

    assert_equal "personal_details", @onboarding.first_incomplete_step
  end

  test "ready_to_complete? only when every step is completed" do
    assert_not @onboarding.ready_to_complete?

    complete_personal_details!
    complete_address!
    assert_not @onboarding.ready_to_complete?

    complete_preferences!
    assert_predicate @onboarding, :ready_to_complete?
  end

  test "complete! stamps completed_at when every step is completed" do
    complete_personal_details!
    complete_address!
    complete_preferences!

    assert @onboarding.complete!
    assert_predicate @onboarding.reload, :completed?
  end

  test "complete! refuses while steps are incomplete" do
    complete_personal_details!

    assert_not @onboarding.complete!
    assert_not @onboarding.reload.completed?
  end

  test "complete! does not move the timestamp once completed" do
    complete_personal_details!
    complete_address!
    complete_preferences!
    @onboarding.complete!
    first_stamp = @onboarding.reload.completed_at

    travel 1.hour do
      assert_not @onboarding.complete!
    end

    assert_equal first_stamp, @onboarding.reload.completed_at
  end
end
