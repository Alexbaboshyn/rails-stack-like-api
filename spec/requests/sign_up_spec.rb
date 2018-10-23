require 'rails_helper'

RSpec.describe 'SignUp', type: :request do
  let!(:user) { create(:user) }

  let!(:resource_params) { attributes_for(:user) }

  let!(:params) { { user: resource_params } }

  let(:headers) { { 'Accept' => 'application/json' } }

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

  let(:user_response) do
    {
      'id' => user.id,
      'first_name' => user.first_name,
      'last_name' => user.last_name,
      'email' => user.email,
      'self_questions' => self_questions,
      'self_answers' => self_answers,
      'auth_tokens' => user.auth_tokens.map { |token| { "value" => token.value } }
    }
  end

  # context 'user was created' do
  #   before { post '/profile', params: params, headers: headers }

  #   it('returns created user') { expect(JSON.parse(response.body)).to eq user_response }

  #   it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  # end

  context 'invalid params were sent' do
    before { post '/profile', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
