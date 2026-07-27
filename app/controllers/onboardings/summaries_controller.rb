class Onboardings::SummariesController < ApplicationController
  include OnboardingScoped

  before_action :require_completed_steps

  def show
  end

  private

  # The summary must show a full set of answers; anyone arriving early is
  # sent to the step they still have to finish.
  def require_completed_steps
    return if @onboarding.completed? || @onboarding.ready_to_complete?

    redirect_to public_send("onboarding_#{@onboarding.first_incomplete_step}_path")
  end
end
