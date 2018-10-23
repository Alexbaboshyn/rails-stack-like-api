require 'rails_helper'

RSpec.describe 'CreateAnswer', type: :request do
  let(:user) { create(:user)}

  let(:value) { user.auth_tokens.last.value }

  let(:headers) do
     {
       'Authorization' => "Token token=#{value}",
       'Content-type' => 'application/json',
       'Accept' => 'application/json'
     }
  end

  let!(:question) { create(:question, id: 1) }

  let(:params) { { answer: resource_params } }

  let(:resource_params) { attributes_for(:answer) }

  before { create(:answer, resource_params.merge(user: user, question: question)) }

  let(:answer) { Answer.last }

  let(:answer_response) do
    {
      "id" => answer.id,
      "body" => answer.body,
      "rating" => answer.rating,
      "author" => author
    }
  end

  let(:author) do
    {
      "id" => answer.user.id,
      "reputation" => answer.user.reputation,
      "name" => "#{ answer.user.first_name } #{ answer.user.last_name }"
    }
  end

  before { post '/questions/1/answers', params: params.to_json, headers: headers }

  context do
    it('returns created answer') { expect(JSON.parse(response.body)).to eq answer_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { post '/questions/1/answers', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'question was not found' do
    before { post '/questions/0/answers', params: params.to_json, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end

  context 'invalid params' do
    before { post '/questions/1/answers', params: {}, headers: headers }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
