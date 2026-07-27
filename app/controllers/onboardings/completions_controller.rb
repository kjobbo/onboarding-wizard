class Onboardings::CompletionsController < ApplicationController
  include OnboardingScoped

  def create
    @onboarding.complete!

    redirect_to onboarding_summary_path, status: :see_other
  end
end
