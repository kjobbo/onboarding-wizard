module OnboardingStep
  extend ActiveSupport::Concern

  included do
    belongs_to :onboarding, touch: true
  end

  def completed?
    completed_at.present?
  end

  def completed!
    return if completed?

    update_column(:completed_at, Time.current)
  end
end
