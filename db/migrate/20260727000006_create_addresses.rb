class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :onboarding, null: false, foreign_key: true, index: { unique: true }
      t.datetime :completed_at
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :postcode
      t.string :country
      t.timestamps
    end
  end
end
