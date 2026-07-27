require "test_helper"

class Onboardings::PersonalDetailsTest < ActiveSupport::TestCase
  setup do
    @onboarding = Onboarding.create!
  end

  def valid_params(attributes = {})
    @onboarding.build_personal_details({
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe@example.com"
    }.merge(attributes))
  end

  test "table name maps to personal_details" do
    assert_equal "personal_details", Onboardings::PersonalDetails.table_name
  end

  test "is valid with first name, last name and email" do
    assert_predicate valid_params, :valid?
  end

  test "requires first_name, last_name and email" do
    details = valid_params(first_name: "", last_name: "", email: "")

    assert_not details.valid?
    assert_includes details.errors[:first_name], "can't be blank"
    assert_includes details.errors[:last_name], "can't be blank"
    assert_includes details.errors[:email], "can't be blank"
  end

  test "rejects names longer than 60 characters" do
    details = valid_params(first_name: "a" * 61, last_name: "b" * 61)

    assert_not details.valid?
    assert details.errors.of_kind?(:first_name, :too_long)
    assert details.errors.of_kind?(:last_name, :too_long)
  end

  test "rejects malformed email addresses" do
    # Note: URI::MailTo::EMAIL_REGEXP permits dotless domains ("user@host"),
    # so that case is deliberately absent here.
    [ "plainaddress", "@missing-local.com", "spaces in@address.com", "missing-at.com" ].each do |email|
      details = valid_params(email: email)

      assert_not details.valid?, "expected #{email.inspect} to be invalid"
      assert_includes details.errors[:email], "must be a valid email address"
    end
  end

  test "full_name joins first and last name, skipping blanks" do
    assert_equal "Joe Bloggs", valid_params.full_name
    assert_equal "Joe", valid_params(last_name: nil).full_name
    assert_equal "", valid_params(first_name: nil, last_name: "").full_name
  end

  test "is not completed until completed_at is set" do
    details = valid_params

    assert_not details.completed?
    details.completed_at = Time.current
    assert_predicate details, :completed?
  end

  test "completed! stamps completed_at once and is idempotent" do
    details = valid_params.tap(&:save!)

    details.completed!
    first_stamp = details.reload.completed_at
    assert_not_nil first_stamp

    travel 1.hour do
      details.completed!
    end

    assert_equal first_stamp, details.reload.completed_at
  end

  test "saving personal details touches the parent onboarding" do
    details = valid_params.tap(&:save!)
    original = @onboarding.reload.updated_at

    travel 1.hour do
      details.update!(first_name: "Joseph")
    end

    assert_operator @onboarding.reload.updated_at, :>, original
  end
end
