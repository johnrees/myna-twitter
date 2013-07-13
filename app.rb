require 'dotenv'
Dotenv.load

require 'sinatra'
require 'twitter'
require 'ostruct'

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

before do
  headers['Access-Control-Allow-Origin'] = '*'
  unless settings.environment == :development
    mins = 2
    headers['Cache-Control'] = "public, max-age=#{60*mins}"
  end
end

get '/user_timeline/:screen_name' do
  tweets = []
  params[:count] ||= 10
  Twitter.user_timeline(params[:screen_name], count: params[:count]).each do |tweet|
    unless false#tweet.in_reply_to_screen_name
      tweets.push OpenStruct.new({
        created_at: tweet.created_at,
        text: tweet.text
      })
    end
  end
  tweets.map { |o| Hash[o.each_pair.to_a] }.to_json
end
