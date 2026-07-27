class CreateOnboardings < ActiveRecord::Migration[8.1]
  def change
    create_table :onboardings do |t|
      t.string :token, null: false, index: { unique: true }
      t.string :current_step, null: false, default: "personal_details"
      t.datetime :completed_at
      t.timestamps
    end
  end
end
