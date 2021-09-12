RSpec.shared_examples 'url validation' do |attribute|
  INVALID_URLS ||= [
    'invalidurl',
    'inval.lid/urlexample',
    'javascript:dangerousJs()//http://www.validurl.com',
    # Literal array syntax is required for \n to be parsed
    "http://www.validurl.com\n<script>dangerousJs();</script>",
    'http://foo.bar?q=Spaces should be encoded'
  ].freeze

  VALID_URLS ||= [
    'http://validurl.com',
    'https://validurl.com/blah_blah',
    'https://www.validurl.com/foo/?bar=baz&inga=42&quux'
  ].freeze

  context "with invalid URLs in #{attribute}" do
    INVALID_URLS.each do |url|
      it "is invalid with #{url.dump}" do
        object = FactoryBot.build(factory_name(subject), attribute => url)
        object.valid?
        expect(object.errors[attribute]).to include('is invalid')
      end
    end
  end

  context "with valid URLs in #{attribute}" do
    VALID_URLS.each do |url|
      it "is valid with #{url}" do
        object = FactoryBot.build(factory_name(subject), attribute => url)
        expect(object).to be_valid
      end
    end
  end
end
