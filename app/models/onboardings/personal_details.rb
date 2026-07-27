class Onboardings::PersonalDetails < ApplicationRecord
  belongs_to :onboarding, touch: true

  validates :first_name, presence: true, length: { maximum: 60 }
  validates :last_name,  presence: true, length: { maximum: 60 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP,
                              message: "must be a valid email address" }

  def full_name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def completed?
    completed_at.present?
  end

  def completed!
    return if completed?

    update_column(:completed_at, Time.current)
  end
end
