FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }

    last_name  { FFaker::Name.last_name }

    email      { FFaker::Internet.email }

    password   { FFaker::Internet.password }

    reputation { 0 }

    after :create do |user|
      create_list :auth_token, 1, user_id: user.id
    end

    trait :with_questions_and_answers do
      after :create do |user|
        create_list :question, 2, user: user

        create_list :answer, 4, user: user

        user.update!(reputation: (user.answers.sum(:rating) + user.questions.sum(:rating)))
      end
    end
  end
end
