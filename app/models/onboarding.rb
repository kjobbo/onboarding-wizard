class Onboarding < ApplicationRecord
  has_secure_token :token
end
