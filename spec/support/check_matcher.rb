# RSpec::Matchers.define :be_a_multiple_of do |expected|
#   match do |actual|
#     actual % expected == 0
#   end
# end
# 9.should be_a_multiple_of(3)

RSpec::Matchers.define :have_message do |message|
  match do |actual|
    actual.check
    actual.message.include? message
  end

  failure_message_for_should do |actual|
    "expected '#{actual.message}' to include '#{message}'"
  end

  failure_message_for_should_not do |actual|
    "expected '#{actual.message}' to not include '#{message}'"
  end
end

RSpec::Matchers.define :be_successful do |message|
  match do |actual|
    actual.check
    actual.success?
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to be successful"
  end

  failure_message_for_should_not do |actual|
    "expected '#{actual}' to not be successful"
  end
end
