require 'rails_helper'

RSpec.describe 'RateQuestion', type: :request do
  let(:user) { create(:user, :with_auth_token)}

  let(:value) { user.auth_token.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let!(:question) { create(:question, id: 1, rating: 0) }

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

  let(:params) { { rate: { kind: 'positive' } } }

  before { post '/questions/1/rate', params: params.to_json, headers: headers }

  context 'positive rate' do
    let(:question_response) do
      {
        "id" => question.id,
        "title" => question.title,
        "body" => question.body,
        "rating" => 1,
        "author" => author,
        "answers" => answers
      }
    end

    let(:author) do
      {
        "id" => question.user.id,
        "reputation" => 1,
        "name" => "#{ question.user.first_name } #{ question.user.last_name }"
      }
    end

    it('returns rated question') { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'negative rate' do
    let(:params) { { rate: { kind: 'negative' } } }

    let(:question_response) do
      {
        "id" => question.id,
        "title" => question.title,
        "body" => question.body,
        "rating" => -1,
        "author" => author,
        "answers" => answers
      }
    end

    let(:author) do
      {
        "id" => question.user.id,
        "reputation" => -1,
        "name" => "#{ question.user.first_name } #{ question.user.last_name }"
      }
    end

    it('returns rated question') { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { post '/questions/1/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'question was not found' do
    before { post '/questions/0/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end

  context 'invalid params' do
    before { post '/questions/1/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
