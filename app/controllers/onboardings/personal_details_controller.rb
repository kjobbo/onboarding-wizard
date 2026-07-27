class Onboardings::PersonalDetailsController < Onboardings::StepController
  before_action :set_personal_details

  private

  def set_personal_details
    @personal_details = @onboarding.personal_details || @onboarding.build_personal_details
  end

  def step_record
    @personal_details
  end

  def next_step
    "address"
  end

  def step_params
    params.expect(personal_details: %i[first_name last_name email])
  end
end
