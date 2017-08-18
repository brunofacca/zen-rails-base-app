FactoryGirl.define do
  factory :contact_form do
    name 'John Doe'
    email 'john@doe.com'
    message 'Hello'

    trait :invalid do
      email nil
    end
  end
end
