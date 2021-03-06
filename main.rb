require 'discordrb'
require 'rest-client'
require 'time'
require 'dotenv/load'

CLIPIA_KEY = ENV['clipia_key']
BASE_URL = "https://clipia.ca"

bot = Discordrb::Bot.new(token: ENV['token'])

bot.message do |e|
    match = e.message.to_s.match(/https:\/\/(www\.)?clipia\.ca\/media\/(\d+)\/?/)
    next unless match
    id = match[2]
    response = RestClient.get("#{BASE_URL}/api/v1/media/#{id}", {
        Authorization: "Bearer #{CLIPIA_KEY}"
    })
    json = JSON.parse(response.body)
    embed = Discordrb::Webhooks::Embed.new(
        title: json['title'], 
        url: "#{BASE_URL}#{json['url']}", 
        timestamp: Time.parse(json['created_at']),
        description: json['description'],
        image: Discordrb::Webhooks::EmbedImage.new(url: json['thumbnail_url']),
        author: Discordrb::Webhooks::EmbedAuthor.new(name: json['author']),
        footer: Discordrb::Webhooks::EmbedFooter.new(text: "#{json['views']} views")
    )

   e.respond nil, false, embed
end

bot.run