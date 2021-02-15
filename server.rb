require "sinatra"
require_relative "lib/twitter"

if development?
  require "sinatra/reloader"
  require "pp"
end

APP_NAME = "I want to Resonate😉"
ALLOWED_MAX_TWEETS_COUNT = "100"
TWITTER_URL = "https://twitter.com/"

# Environment variable of PORT will be initiated in heroku production environment
unless ENV["PORT"].nil?
  set :port, ENV["PORT"]
end

get "/" do
  @app_name = APP_NAME

  @tweets = {}
  @authors = {}

  # keywords = ["猫", "犬", "ネズミ", "サル", "クジラ", "タコ", "コアラ", "パンダ", "ゴリラ", "イルカ", "トンビ", "カンガルー"]
  keywords = ["nodejs", "javascript", "html", "css", "ruby", "php", "python", "go", "java", "kotlin", "swift"]
  @sample = keywords.sample

  search_results = search_tweets_by_keyword keyword: @sample
  @tweets = search_results[:tweets]
  @authors = search_results[:authors]

  erb :index
end

post "/" do
  @app_name = "Click to randamly Resonate"

  return redirect back if params[:keyword].empty? || params[:keyword].nil?

  @tweets = {}
  @authors = {}

  search_results = search_tweets_by_keyword keyword: params[:keyword], max_results: ALLOWED_MAX_TWEETS_COUNT
  @tweets = search_results[:tweets]
  @authors = search_results[:authors]

  erb :index
end


def search_tweets_by_keyword(keyword: "", max_results: "30")
  twitter = Twitter.new
  tweets = {}
  authors = {}

  response = twitter.search keyword: keyword, max_results: max_results
  response.each do |value|
    case value[0]
    when "data"
      tweets = value[1]
    when "includes"
      value[1]["users"].each do |user|
        authors[user["id"]] = {name: user["name"], username: user["username"]}
      end
    end
  end

  {tweets: tweets, authors: authors}
end