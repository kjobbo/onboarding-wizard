class Onboarding < ApplicationRecord
  has_secure_token :token

  has_one :personal_details, class_name: "Onboardings::PersonalDetails", dependent: :destroy
end
