class OnboardingsController < ApplicationController
  include OnboardingScoped
  skip_before_action :set_onboarding, only: %i[new create]

  def new; end

  def create
    @onboarding = Onboarding.find_by(token: session[:onboarding_token]) || Onboarding.create!
    session[:onboarding_token] = @onboarding.token

    redirect_to onboarding_path, status: :see_other
  end

  # Routes the visitor to the screen for their current step.
  def show
    redirect_to public_send("onboarding_#{@onboarding.current_step}_path")
  end
end
