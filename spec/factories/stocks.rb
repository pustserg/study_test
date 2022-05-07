FactoryBot.define do
  factory :stock do
    bearer
    name { Faker::Name.unique.name }
  end
end
