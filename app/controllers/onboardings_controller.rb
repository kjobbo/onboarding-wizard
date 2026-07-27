class OnboardingsController < ApplicationController
  include OnboardingScoped
  skip_before_action :set_onboarding, only: %i[new create]

  def new; end

  def create
    @onboarding = Onboarding.find_by(token: session[:onboarding_token]) || Onboarding.create!
    session[:onboarding_token] = @onboarding.token

    redirect_to onboarding_path, status: :see_other
  end

  # Routes the visitor to their current step; the placeholder below the
  # redirect renders for steps that do not have screens yet.
  def show
    redirect_to onboarding_personal_details_path if @onboarding.current_step == "personal_details"
  end
end
