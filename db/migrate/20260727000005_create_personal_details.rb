class CreatePersonalDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :personal_details do |t|
      t.references :onboarding, null: false, foreign_key: true, index: { unique: true }
      t.datetime :completed_at
      t.string :first_name
      t.string :last_name
      t.string :email
      t.timestamps
    end
  end
end
