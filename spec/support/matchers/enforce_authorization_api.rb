# frozen_string_literal: true

RSpec::Matchers.define :enforce_authorization_api do
  expected_error =
    { 'error' => 'User is not authorized to access this resource.' }

  match do |actual|
    expect(actual).to have_http_status(403)
    expect(JSON.parse(actual.body)).to eq(expected_error)
  end

  failure_message do |actual|
    "expected to receive 403 status code (forbidden) and '#{expected_error}' " \
      "as the response body. Received #{actual.status} status and "\
      "'#{JSON.parse(actual.body)}' response body instead."
  end

  failure_message_when_negated do
    "expected not to receive 403 status (forbidden) or '#{expected_error}' "\
      'in the response body, but it did.'
  end

  description do
    'enforce authorization policies when accessing API resources.'
  end
end
