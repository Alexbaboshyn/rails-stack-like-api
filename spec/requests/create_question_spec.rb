require 'rails_helper'

RSpec.describe 'CreateQuestion', type: :request do
  let(:user) { create(:user, :with_auth_token)}

  let(:value) { user.auth_token.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let(:params) { { question: resource_params } }

  let(:resource_params) { attributes_for(:question) }

  before { create(:question, resource_params.merge(user: user)) }

  let(:question) { Question.last }

  let(:question_response) do
    {
      "id" => question.id,
      "title" => question.title,
      "body" => question.body,
      "rating" => question.rating,
      "author" => author,
      "answers" => answers
    }
  end

  let(:author) do
    {
      "id" => question.user.id,
      "reputation" => question.user.reputation,
      "name" => "#{ question.user.first_name } #{ question.user.last_name }"
    }
  end

  let(:answers) do
    question.answers.order('rating DESC').map do |answer|
      {
        "id" => answer.id,
        "rating" => answer.rating,
        "body" => answer.body,
        "author" => {
          "id" => answer.user.id,
          "reputation" => answer.user.reputation,
          "name" => "#{ answer.user.first_name } #{ answer.user.last_name }"
        }
      }
    end
  end

  before { post '/questions', params: params.to_json, headers: headers }

  context do
    it('returns auth_token') { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { post '/questions', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'invalid params' do
    before { post '/questions', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
