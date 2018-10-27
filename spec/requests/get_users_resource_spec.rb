require 'rails_helper'

RSpec.describe 'GetUsersResource', type: :request do
  let!(:user) { create(:user, :with_questions_and_answers, id: 1) }

  let(:headers) { { 'Accept' => 'application/json' } }

  let(:self_questions) do
    user.questions.order('rating DESC').map do |question|
      { "id" => question.id, "rating" => question.rating, "title" => question.title }
    end
  end

  let(:answered_questions) do
    Question.joins(:answers).where(answers:{ user_id: user.id}).order('rating DESC').map do |question|
      { "id" => question.id, "rating" => question.rating, "title" => question.title }
    end
  end

  let(:user_response) do
    {
      "id" => user.id,
      "email" => user.email,
      "name" => "#{ user.first_name } #{ user.last_name }",
      "reputation" => user.reputation,
      "answered_questions" => answered_questions,
      "self_questions" => self_questions
    }
  end

  context do
    before { get '/users/1', params: {} , headers: headers }

    it("returns user's information") { expect(JSON.parse(response.body)).to eq user_response }
  end

  context 'user was not found' do
    before { get '/users/0', params: {} , headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end
end
