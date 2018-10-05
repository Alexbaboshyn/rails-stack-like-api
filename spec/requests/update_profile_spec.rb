require 'rails_helper'

RSpec.describe 'UpdateProfile', type: :request do
  let(:user) { create(:user, :with_auth_token, :with_questions_and_answers)}

  let(:value) { user.auth_token.value }

  let(:headers) { { 'Authorization' => "Token token=#{value}", 'Content-type' => 'application/json', 'Accept' => 'application/json' } }

  let(:params) { { user: { first_name: "Ben", last_name: "Gun", email: "new@email.com" } } }

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
      "email" => "new@email.com",
      "first_name" => "Ben",
      "last_name" => "Gun",
      "reputation" => user.reputation,
      "self_answers" => self_answers,
      "self_questions" => self_questions
    }
  end

  context do
    before { put '/profile', params: params.to_json, headers: headers }

    it('returns updated_profile') { expect(JSON.parse(response.body)).to eq profile_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'invalid attributes' do
    before { put '/profile', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { put '/profile', params: {} , headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end
end
