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

  let!(:question) { create(:question, :with_rate, id: 1, rating: 1, user: user) }

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

  before { delete '/questions/1/rate', params: {}, headers: headers }

  context 'rate deleted' do
    let(:question_response) do
      {
        "id" => question.id,
        "title" => question.title,
        "body" => question.body,
        "rating" => 0,
        "author" => author,
        "answers" => answers
      }
    end

    let(:author) do
      {
        "id" => question.user.id,
        "reputation" => 0,
        "name" => "#{ question.user.first_name } #{ question.user.last_name }"
      }
    end

    it('returns question with updated rate') { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'tried to delete not self rate' do
    let(:stranger) { create(:user)}

    let(:value) { stranger.auth_tokens.last.value }

    it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
  end

  context 'Unauthorized' do
    let(:value) { SecureRandom.uuid }

    before { delete '/questions/1/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 401') { expect(response).to have_http_status :unauthorized }
  end

  context 'question was not found' do
    before { delete '/questions/0/rate', params: {}, headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end
end
