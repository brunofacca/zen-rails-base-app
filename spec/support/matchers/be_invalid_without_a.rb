RSpec::Matchers.define :be_invalid_without_a do |attribute, **factory_args|
  match do |model|
    object = FactoryGirl.build(factory_name(model), factory_args)
    # "Collection attributes" do not accept nil as a value, other attributes do.
    # Use send as "object[attribute]" syntax does not work with associations
    empty_value = object.send(attribute).respond_to?(:each) ? [] : nil
    object.send("#{attribute}=", empty_value)
    object.valid?
    expect(object.errors[attribute]).to include("can't be blank")
  end
end
