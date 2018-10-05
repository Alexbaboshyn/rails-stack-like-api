require 'rails_helper'

RSpec.describe 'RateAnswer', type: :request do
  let(:user) { create(:user, :with_auth_token)}

  let(:value) { user.auth_token.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let!(:answer) { create(:answer, id: 1, rating: 0) }

  let(:params) { { rate: { kind: 'positive' } } }

  before { post '/answers/1/rate', params: params.to_json, headers: headers }

  context 'positive rate' do
    let(:answer_response) do
      {
        "id" => answer.id,
        "body" => answer.body,
        "rating" => 1,
        "author" => author
      }
    end

    let(:author) do
      {
        "id" => answer.user.id,
        "reputation" => 1,
        "name" => "#{ answer.user.first_name } #{ answer.user.last_name }"
      }
    end

    it('returns rated answer') { expect(JSON.parse(response.body)).to eq answer_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'negative rate' do
    let(:params) { { rate: { kind: 'negative' } } }

    let(:answer_response) do
      {
        "id" => answer.id,
        "body" => answer.body,
        "rating" => -1,
        "author" => author
      }
    end

    let(:author) do
      {
        "id" => answer.user.id,
        "reputation" => -1,
        "name" => "#{ answer.user.first_name } #{ answer.user.last_name }"
      }
    end

    it('returns rated answer') { expect(JSON.parse(response.body)).to eq answer_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { post '/answers/1/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'answer was not found' do
    before { post '/answers/0/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end

  context 'invalid params' do
    before { post '/answers/1/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
