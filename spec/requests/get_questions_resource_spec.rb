require 'rails_helper'

RSpec.describe 'GetQuestionsResource', type: :request do
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

  let(:author) do
    {
      "id" => question.user.id,
      "reputation" => question.user.reputation,
      "name" => "#{ question.user.first_name } #{ question.user.last_name }"
    }
  end

  let(:question_response) do
    {
      "id" => question.id,
      "title" => question.title,
      "body" => question.body,
      "rating" => question.rating,
      "author" => author,
      "answers" => answers
    }
  end

  context do
    before { get '/questions/1', params: {} , headers: headers }

    it("returns question's information") { expect(JSON.parse(response.body)).to eq question_response }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end

  context 'question was not found' do
    before { get '/questions/0', params: {} , headers: headers }

    it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
  end
end
