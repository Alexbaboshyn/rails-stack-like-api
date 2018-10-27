require 'rails_helper'

RSpec.describe 'SignIn', type: :request do
  let(:user) { create(:user)}

  let(:token) { AuthToken.create(user_id: user.id) }

  let(:params) { { session: { email: user.email, password: user.password } } }

  let(:headers) { { 'Accept' => 'application/json' } }

  let(:token_response) { { "auth_token" => user.auth_tokens.last.value } }

  before { post '/session', params: params, headers: headers }

  context 'authenticated' do
    it('returns auth_token') { expect(JSON.parse(response.body)).to eq token_response }
  end

  context 'not authenticated' do
    let(:params) { { session: { email: "email", password: "password" } } }

    it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
  end
end
