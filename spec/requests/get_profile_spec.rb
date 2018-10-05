require 'rails_helper'

RSpec.describe 'GetProfile', type: :request do
  let(:user) { create(:user, :with_auth_token, :with_questions_and_answers)}

  let(:value) { user.auth_token.value }

  let(:headers) { { 'Authorization' => "Token token=#{value}", 'Content-type' => 'application/json', 'Accept' => 'application/json' } }

  let(:self_questions) do
    user.questions.order('rating DESC').map do |question|
      { "id" => question.id, "rating" => question.rating, "title" => question.title }
    end
  end

  let(:self_answers) do
    user.answers.order('rating DESC').map do |answer|
      { "id" => answer.id, "rating" => answer.rating, "body" => answer.body }
    end
  end

  let(:profile_response) do
    {
      "id" => user.id,
      "email" => user.email,
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "reputation" => user.reputation,
      "self_answers" => self_answers,
      "self_questions" => self_questions
    }
  end

  context do
    before { get '/profile', params: {} , headers: headers }

    it('returns profile') { expect(JSON.parse(response.body)).to eq profile_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { get '/profile', params: {} , headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end
end
