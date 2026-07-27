class Onboardings::Preferences < ApplicationRecord
  include OnboardingStep

  PLANS = %w[starter standard pro].freeze
  BILLING_PERIODS = %w[monthly annual].freeze

  validates :plan, inclusion: { in: PLANS, message: "must be one of the available plans" }
  validates :billing_period, inclusion: { in: BILLING_PERIODS, message: "must be monthly or annual" }
end
