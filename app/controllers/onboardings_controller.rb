class OnboardingsController < ApplicationController
  include OnboardingScoped
  skip_before_action :set_onboarding, only: %i[new create]

  def new; end

  def create
    @onboarding = Onboarding.find_by(token: session[:onboarding_token]) || Onboarding.create!
    session[:onboarding_token] = @onboarding.token

    redirect_to onboarding_path, status: :see_other
  end

  def show; end
end
