class Onboarding < ApplicationRecord
  has_secure_token :token

  has_one :personal_details, class_name: "Onboardings::PersonalDetails", dependent: :destroy
  has_one :address, class_name: "Onboardings::Address", dependent: :destroy
  has_one :preferences, class_name: "Onboardings::Preferences", dependent: :destroy
end
