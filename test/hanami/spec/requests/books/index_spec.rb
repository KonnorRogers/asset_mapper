# spec/requests/books/index_spec.rb

RSpec.describe "GET /books", type: :request do
  it "returns a list of books" do
    get "/books"

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq("application/json; charset=utf-8")

    response_body = JSON.parse(last_response.body)

    expect(response_body).to eq([
      { "title" => "Test Driven Development" },
      { "title" => "Practical Object-Oriented Design in Ruby" }
    ])
  end
end
