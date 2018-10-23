require 'rails_helper'

RSpec.describe 'DeleteRateForQuestion', type: :request do
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

  before { delete '/answers/1/rate', params: {}, headers: headers }

  context 'rate deleted' do
    let(:answer_response) do
      {
        "id" => answer.id,
        "body" => answer.body,
        "rating" => 0,
        "author" => author
      }
    end

    let(:author) do
      {
        "id" => answer.user.id,
        "reputation" => 0,
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

    before { delete '/answers/1/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'answer was not found' do
    before { delete '/answers/0/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end
end
