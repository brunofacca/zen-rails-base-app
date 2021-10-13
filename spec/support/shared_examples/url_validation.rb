# frozen_string_literal: true

RSpec.shared_examples 'url validation' do |attribute|
  invalid_urls = [
    'invalidurl',
    'inval.lid/urlexample',
    'javascript:dangerousJs()//http://www.validurl.com',
    # Literal array syntax is required for \n to be parsed
    "http://www.validurl.com\n<script>dangerousJs();</script>",
    'http://foo.bar?q=Spaces should be encoded'
  ]

  valid_urls = %w[http://validurl.com https://validurl.com/blah_blah https://www.validurl.com/foo/?bar=baz&inga=42&quux]

  context "with invalid URLs in #{attribute}" do
    invalid_urls.each do |url|
      it "is invalid with #{url.dump}" do
        object = FactoryBot.build(factory_name(subject), attribute => url)
        object.valid?
        expect(object.errors[attribute]).to include('is invalid')
      end
    end
  end

  context "with valid URLs in #{attribute}" do
    valid_urls.each do |url|
      it "is valid with #{url}" do
        object = FactoryBot.build(factory_name(subject), attribute => url)
        expect(object).to be_valid
      end
    end
  end
end
