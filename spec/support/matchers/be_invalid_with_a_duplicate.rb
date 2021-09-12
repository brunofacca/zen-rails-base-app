RSpec::Matchers.define :be_invalid_with_a_duplicate do |attribute|
  match do |model|
    factory = factory_name(model)
    # Create a valid value for the tested attribute
    duplicated_value = FactoryBot.attributes_for(factory)[attribute]
    # The first object needs to be persisted for the validation to work
    FactoryBot.create(factory, attribute => duplicated_value)
    object = FactoryBot.build(factory, attribute => duplicated_value)
    object.valid?
    expect(object.errors[attribute]).to include('has already been taken')
  end
end
