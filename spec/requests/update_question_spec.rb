require 'rails_helper'

RSpec.describe 'UpdateQuestion', type: :request do
  let(:user) { create(:user)}

  let(:value) { user.auth_tokens.last.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let(:params) { { question: {title: 'new title', body: 'new body'} } }

  let!(:question) { create(:question, :with_rate, id: 1, rating: 1, user: user) }

  let(:question_response) do
    {
      "id" => question.id,
      "title" => 'new title',
      "body" => 'new body',
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

  before { put '/questions/1', params: params.to_json, headers: headers }

  context do
    it('returns updated question') { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { put '/questions/1', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'invalid params' do
    before { put '/questions/1', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end

  context 'question was not found' do
    before { put '/questions/-1', params: {}, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end

  context 'user tries to update not self question' do
    let(:stranger) { create(:user)}

    let(:value) { stranger.auth_tokens.last.value }

    before { put '/questions/1', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
  end
end
