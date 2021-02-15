require 'net/http'
require 'uri'
require 'json'


class Twitter
  BEARER = "Bearer #{ENV["TWITTER_API_BEARER_TOKEN"]}"

  def search(keyword: "", max_results: "10")
    params = [["expansions", "author_id"],["query", keyword],["max_results", max_results],["tweet.fields", "entities"]]
    params = URI.encode_www_form params
    uri = URI.parse("https://api.twitter.com/2/tweets/search/recent?#{params}")

    header = {"Authorization" => BEARER}

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri, header)
    end

    case
    when response.kind_of?(Net::HTTPSuccess)
      JSON.parse(response.body)
    when response.kind_of?(Net::HTTPClientError) || response.kind_of?(Net::HTTPServerError)
      "HTTP ERROR: code=#{response.code} message=#{response.message}"
    else
      raise RuntimeError, "Something went wrong"
    end
  end
end



if $0 == __FILE__
  begin
    twitter = Twitter.new
    tweets = twitter.search keyword: "猫"
    puts tweets.to_json
    # tweets.each_with_index do |value, index|
    #   if value[0] == "data"
    #     value[1].each do |v|
    #       puts v["author_id"]
    #       puts v["id"]
    #       puts v["text"]
    #       puts "------------\n"
    #     end
    #   end
    # end
  rescue IOError => e
    puts e.message
  rescue JSON::ParserError => e
    puts e.message
  rescue => e
    puts e.message
  end
end