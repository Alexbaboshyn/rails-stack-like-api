require 'rails_helper'

RSpec.describe 'SignOut', type: :request do
  let(:user) { create(:user, :with_auth_token)}

  let(:value) { user.auth_token.value }

  let(:headers) { { 'Authorization' => "Token token=#{value}", 'Content-type' => 'application/json', 'Accept' => 'application/json' } }

  context do
    before { delete '/session', params: {} , headers: headers }

    before { user.reload }

    it("destroys current_user's auth_token") { expect(user.auth_token).to eq nil }

    it('returns HTTP Status Code 204') { expect(response).to have_http_status 204 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { delete '/session', params: {} , headers: headers }

    before { user.reload }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end
end
