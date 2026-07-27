require "test_helper"

class Onboardings::PreferencesTest < ActiveSupport::TestCase
  setup do
    @onboarding = Onboarding.create!
  end

  def valid_params(attributes = {})
    @onboarding.build_preferences({
      plan: "standard",
      billing_period: "monthly"
    }.merge(attributes))
  end

  test "table name maps to preferences" do
    assert_equal "preferences", Onboardings::Preferences.table_name
  end

  test "rejects unknown or blank plans" do
    [ nil, "", "enterprise" ].each do |plan|
      preferences = valid_params(plan: plan)

      assert_not preferences.valid?, "expected plan #{plan.inspect} to be invalid"
      assert_includes preferences.errors[:plan], "must be one of the available plans"
    end
  end

  test "rejects unknown or blank billing periods" do
    [ nil, "", "weekly" ].each do |period|
      preferences = valid_params(billing_period: period)

      assert_not preferences.valid?, "expected billing_period #{period.inspect} to be invalid"
      assert_includes preferences.errors[:billing_period], "must be monthly or annual"
    end
  end

  test "newsletter_opt_in defaults to false and is never nil" do
    preferences = valid_params.tap(&:save!)

    assert_equal false, preferences.reload.newsletter_opt_in

    preferences.update!(newsletter_opt_in: true)
    assert preferences.reload.newsletter_opt_in
  end

  test "completed! stamps completed_at once and is idempotent" do
    preferences = valid_params.tap(&:save!)

    assert_not preferences.completed?
    preferences.completed!
    first_stamp = preferences.reload.completed_at
    assert_not_nil first_stamp

    travel 1.hour do
      preferences.completed!
    end

    assert_equal first_stamp, preferences.reload.completed_at
  end
end
