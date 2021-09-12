RSpec::Matchers.define :be_invalid_without_a do |attribute, **factory_args|
  match do |model|
    object = FactoryBot.build(factory_name(model), factory_args)
    # "Collection attributes" do not accept nil as a value, other attributes do.
    # Use send as "object[attribute]" syntax does not work with associations
    empty_value = object.send(attribute).respond_to?(:each) ? [] : nil
    object.send("#{attribute}=", empty_value)
    object.valid?
    # Must match Rails default error messages for both "validates :foo,
    # presence: true" and belongs_to, whose presence is validates by default
    # as of Rails 5.
    expect(object.errors[attribute]).to \
      include('can\'t be blank').or include('must exist')
  end
end
