FactoryBot.define do
  factory :rate do
    kind 'positive'

    association :rateable
  end
end
