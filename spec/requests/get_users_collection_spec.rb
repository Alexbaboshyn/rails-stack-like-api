require 'rails_helper'

RSpec.describe 'GetUsersCollection', type: :request do
  before { create_list(:user, 3, :with_questions_and_answers) }

  let(:headers) { { 'Accept' => 'application/json' } }

  let(:users_collection) do
    User.all.order('reputation DESC').map do |user|
      {
        "id" => user.id,
        "email" => user.email,
        "reputation" => user.reputation,
        "name" => "#{ user.first_name } #{ user.last_name }" ,
        "questions_count" => user.questions.count,
        "answers_count" => user.answers.count
      }
    end
  end

  context do
    before { get '/users', params: {} , headers: headers }

    it('returns collection of users') { expect(JSON.parse(response.body)).to eq users_collection }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end
end
