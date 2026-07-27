# Base class for the wizard's form steps. Subclasses set their record in a
# before_action and define three hooks: step_record, step_params and next_step.
class Onboardings::StepController < ApplicationController
  include OnboardingScoped

  def show
  end

  def update
    if step_record.update(step_params)
      step_record.completed!
      @onboarding.update!(current_step: next_step)

      redirect_to onboarding_path, status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  end
end
