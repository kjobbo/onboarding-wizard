class Onboardings::PersonalDetailsController < ApplicationController
  include OnboardingScoped

  before_action :set_personal_details

  def show
  end

  def update
    if @personal_details.update(personal_details_params)
      @personal_details.completed!
      @onboarding.update!(current_step: "address")

      redirect_to onboarding_path, status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_personal_details
    @personal_details = @onboarding.personal_details || @onboarding.build_personal_details
  end

  def personal_details_params
    params.expect(personal_details: %i[first_name last_name email])
  end
end
