require "test_helper"

class OnboardingTest < ActiveSupport::TestCase
  test "generates a token on create" do
    onboarding = Onboarding.create!

    assert onboarding.token.present?
  end
end
