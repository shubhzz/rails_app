class Authentication < ActiveRecord::Base
	belongs_to :user
	require 'koala'

	
	def self.get_feed(object)
		@graph = Koala::Facebook::API.new(object.token)
		profile = @graph.get_object("me")
		my_status = @graph.get_object("/me/statuses", "fields"=>"message")
	end	

	def self.get_tweets(object)
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = "enu3T1yD8AMPQSn1Nqvm61CM7"
		  config.consumer_secret     = "TUYevL7enXlDqUzh9NevUhIKny6IDeKO4TgjIVnkaSsUGXbGv8"
		  config.access_token        = "#{object.token}"
		  config.access_token_secret = "#{object.token_secret}"
		end
		a = client.user_timeline(object.uid.to_i)
	end

	def self.get_gplus_feed(object)
		GooglePlus.api_key = "AIzaSyCsgcLd15U6yJRg-s7RWqIAmPhtBkyg5wY"
		GooglePlus.access_token = "#{object.token}"
		comment = GooglePlus::Comment.get(object.uid.to_i)
	end

end
