class Onboardings::PreferencesController < ApplicationController
  include OnboardingScoped

  before_action :set_preferences

  def show
  end

  def update
    if @preferences.update(preferences_params)
      @preferences.completed!
      @onboarding.update!(current_step: "summary")

      redirect_to onboarding_path, status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_preferences
    @preferences = @onboarding.preferences || @onboarding.build_preferences
  end

  def preferences_params
    params.expect(preferences: %i[plan billing_period newsletter_opt_in])
  end
end
