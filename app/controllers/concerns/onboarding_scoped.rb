module OnboardingScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_onboarding
  end

  private

  def set_onboarding
    @onboarding = Onboarding.find_by(token: session[:onboarding_token])
    redirect_to root_path if @onboarding.nil?
  end
end
