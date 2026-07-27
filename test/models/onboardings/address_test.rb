require "test_helper"

class Onboardings::AddressTest < ActiveSupport::TestCase
  setup do
    @onboarding = Onboarding.create!
  end

  def valid_params(attributes = {})
    @onboarding.build_address({
      address_line_1: "1 High Street",
      address_line_2: "Flat 2",
      city: "London",
      postcode: "SW1A 1AA",
      country: "United Kingdom"
    }.merge(attributes))
  end

  test "table name maps to addresses" do
    assert_equal "addresses", Onboardings::Address.table_name
  end

  test "is valid with line 1, city, postcode and country" do
    assert_predicate valid_params, :valid?
  end

  test "address_line_2 is optional" do
    assert_predicate valid_params(address_line_2: nil), :valid?
  end

  test "requires address_line_1, city, postcode and country" do
    address = valid_params(address_line_1: "", city: "", postcode: "", country: "")

    assert_not address.valid?
    %i[address_line_1 city postcode country].each do |field|
      assert_includes address.errors[field], "can't be blank"
    end
  end

  test "lines returns the populated address lines in order" do
    assert_equal [ "1 High Street", "Flat 2", "London", "SW1A 1AA", "United Kingdom" ],
                 valid_params.lines
  end

  test "lines skips blank components" do
    address = valid_params(address_line_2: "", country: nil)

    assert_equal [ "1 High Street", "London", "SW1A 1AA" ], address.lines
  end

  test "completed! stamps completed_at once and is idempotent" do
    address = valid_params.tap(&:save!)

    assert_not address.completed?
    address.completed!
    first_stamp = address.reload.completed_at
    assert_not_nil first_stamp

    travel 1.hour do
      address.completed!
    end

    assert_equal first_stamp, address.reload.completed_at
  end

  test "saving an address touches the parent onboarding" do
    address = valid_params.tap(&:save!)
    original = @onboarding.reload.updated_at

    travel 1.hour do
      address.update!(city: "Leeds")
    end

    assert_operator @onboarding.reload.updated_at, :>, original
  end

  test "database rejects a second address for the same onboarding" do
    valid_params.save!

    assert_raises ActiveRecord::RecordNotUnique do
      Onboardings::Address.create!(onboarding_id: @onboarding.id,
                                   address_line_1: "2 Low Street", city: "Leeds",
                                   postcode: "LS1 1AA", country: "United Kingdom")
    end
  end
end
