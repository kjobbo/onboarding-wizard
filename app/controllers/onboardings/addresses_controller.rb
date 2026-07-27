class Onboardings::AddressesController < ApplicationController
  include OnboardingScoped

  before_action :set_address

  def show
  end

  def update
    if @address.update(address_params)
      @address.completed!
      @onboarding.update!(current_step: "preferences")

      redirect_to onboarding_path, status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_address
    @address = @onboarding.address || @onboarding.build_address
  end

  def address_params
    params.expect(address: %i[address_line_1 address_line_2 city postcode country])
  end
end
