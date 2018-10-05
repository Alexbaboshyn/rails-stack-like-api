require 'rails_helper'

RSpec.describe 'GetQuestionAnswersCollection', type: :request do
  let!(:question) { create(:question, :with_answers, id: 1) }

  let(:headers) { { 'Accept' => 'application/json' } }

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

  context do
    before { get '/questions/1/answers', params: {} , headers: headers }

    it("returns question's answers") { expect(JSON.parse(response.body)).to eq answers }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'question was not found' do
    before { get '/questions/3/answers', params: {} , headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end
end
