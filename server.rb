require 'sinatra'
require 'redis'

RESPONSES_VS_COUNTS = {
  'biscuit' => 0,
  'unicorn' => 0,
  'ice_cream' => 0,
  'moon_cycle' => 0,
  'flowerpot' => 0
}

get '/' do
  answer = params[:answer]
  unless RESPONSES_VS_COUNTS.keys.include?(answer)
    { totals: "Please try again" }.to_json
  else
    redis = Redis.new(url: ENV["REDIS_URL"])
    stored_responses_vs_counts = redis.get('responses_vs_counts')
    responses_vs_counts = if stored_responses_vs_counts
      JSON.parse(stored_responses_vs_counts)
    else
      RESPONSES_VS_COUNTS
    end
    responses_vs_counts[answer] += 1
    redis.set "responses_vs_counts", responses_vs_counts.to_json

    total_count = responses_vs_counts.inject(0) { |counter, (key, value)| counter + value }
    totals = responses_vs_counts.sort_by do |key, count|
      -count
    end.map do |key, count|
      percentage = ((count/total_count.to_f)*100).round(2) rescue 0
      {
        name: key,
        percentage: percentage
      }
    end

    { totals: totals }.to_json
  end
end
