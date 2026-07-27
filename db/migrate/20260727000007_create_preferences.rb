class CreatePreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :preferences do |t|
      t.references :onboarding, null: false, foreign_key: true, index: { unique: true }
      t.datetime :completed_at
      t.string :plan
      t.string :billing_period
      t.boolean :newsletter_opt_in, null: false, default: false
      t.timestamps
    end
  end
end
