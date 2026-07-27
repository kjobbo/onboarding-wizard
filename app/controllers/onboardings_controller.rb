class OnboardingsController < ApplicationController
  include OnboardingScoped
  skip_before_action :set_onboarding, only: %i[new create]

  def new; end

  def create
    @onboarding = Onboarding.find_by(token: session[:onboarding_token]) || Onboarding.create!
    session[:onboarding_token] = @onboarding.token

    redirect_to onboarding_path, status: :see_other
  end

  # Routes the visitor to their current step; the placeholder renders for
  # steps that do not have screens yet.
  def show
    step_path = "onboarding_#{@onboarding.current_step}_path"
    redirect_to public_send(step_path) if respond_to?(step_path)
  end
end
