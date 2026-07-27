class Onboardings::AddressesController < Onboardings::StepController
  before_action :set_address

  private

  def set_address
    @address = @onboarding.address || @onboarding.build_address
  end

  def step_record
    @address
  end

  def next_step
    "preferences"
  end

  def step_params
    params.expect(address: %i[address_line_1 address_line_2 city postcode country])
  end
end
