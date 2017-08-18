RSpec::Matchers.define :require_login_api do
  expected_error =
    { 'error' => 'You need to sign in or sign up before continuing.' }

  match do
    expect(response).to have_http_status(401)
    expect(JSON.parse(actual.body)).to eq(expected_error)
  end

  failure_message do |actual|
    'expected to receive 401 status code (require login) and '\
    "\"#{expected_error}\" as the response body. Received #{actual.status} "\
    "status and \"#{JSON.parse(actual.body)}\" response body instead."
  end

  failure_message_when_negated do
    'expected not to receive 401 status (require login) or '\
    "\"#{expected_error}\" in the response body, but it did."
  end

  description do
    'require login to access API resources.'
  end
end
