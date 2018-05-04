require 'sinatra'

get '/' do
  response = {
    totals: "Response from server"
  }
  response.to_json
end
