FactoryBot.define do
  factory :answer do
    body { FFaker::Lorem.sentence }

    rating { rand(-10..10) }

    question

    user
  end
end
