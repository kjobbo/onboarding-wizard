class Onboarding < ApplicationRecord
  has_secure_token :token

  has_one :personal_details, class_name: "Onboardings::PersonalDetails", dependent: :destroy
  has_one :address, class_name: "Onboardings::Address", dependent: :destroy
  has_one :preferences, class_name: "Onboardings::Preferences", dependent: :destroy

  STEPS = %w[personal_details address preferences].freeze

  def completed?
    completed_at.present?
  end

  def first_incomplete_step
    STEPS.find { |step| !public_send(step)&.completed? }
  end

  def ready_to_complete?
    first_incomplete_step.nil?
  end

  def complete!
    return false if completed?
    return false unless ready_to_complete?

    update!(completed_at: Time.current)
  end
end
