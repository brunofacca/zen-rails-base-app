RSpec::Matchers.define :have_a_valid_factory do
  match do |model|
    object = FactoryBot.build(factory_name(model))
    expect(object).to be_valid
  end
end
