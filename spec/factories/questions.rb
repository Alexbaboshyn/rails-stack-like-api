FactoryBot.define do
  factory :question do
    title { FFaker::Lorem.phrase }

    body { FFaker::Lorem.sentence }

    rating { rand(-10..10) }

    user
  end

  trait :with_answers do
    after :create do |question|
      create_list :answer, 2, question: question
    end
  end

  trait :with_rate do
    after :create do |question|
      create :rate, user_id: question.user_id, rateable: question
    end
  end
end
