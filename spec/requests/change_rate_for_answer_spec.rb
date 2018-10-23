require 'rails_helper'

RSpec.describe 'ChangeRateForAnswer', type: :request do
  let(:user) { create(:user, reputation: 1)}

  let(:value) { user.auth_tokens.last.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let!(:answer) { create(:answer, :answer_with_rate, id: 1, rating: 1, user: user) }

  let(:params) { { rate: { kind: 'positive' } } }

  before { put '/answers/1/rate', params: params.to_json, headers: headers }

  context 'new rate has the same kind as it was' do
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

    it('returns unchanged data') { expect(JSON.parse(response.body)).to eq answer_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'new rate has opposite kind (become negative)' do
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

    it('returns answer with updated rate') { expect(JSON.parse(response.body)).to eq answer_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'tried to update not self rate' do
    let(:stranger) { create(:user)}

    let(:value) { stranger.auth_tokens.last.value }

    it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { put '/answers/1/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'answer was not found' do
    before { put '/answers/0/rate', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end

  context 'invalid params' do
    before { put '/answers/1/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
