class Onboardings::PreferencesController < Onboardings::StepController
  before_action :set_preferences

  private

  def set_preferences
    @preferences = @onboarding.preferences || @onboarding.build_preferences
  end

  def step_record
    @preferences
  end

  def next_step
    "summary"
  end

  def step_params
    params.expect(preferences: %i[plan billing_period newsletter_opt_in])
  end
end
