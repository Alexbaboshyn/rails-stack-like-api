FactoryBot.define do
  factory :answer do
    body { FFaker::Lorem.sentence }

    rating { rand(-10..10) }

    question

    user
  end

  trait :answer_with_rate do
    after :create do |answer|
      create :rate, user_id: answer.user_id, rateable: answer
    end
  end
end
