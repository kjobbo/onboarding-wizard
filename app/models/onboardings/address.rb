class Onboardings::Address < ApplicationRecord
  include OnboardingStep

  validates :address_line_1, :city, :postcode, :country, presence: true

  def lines
    [ address_line_1, address_line_2, city, postcode, country ].compact_blank
  end
end
