RSpec::Matchers.define :find_records_by_slug do
  match do |model|
    object = FactoryBot.create(factory_name(model))
    expect(model.friendly.find(object.slug)).to eq(object)
  end
end
