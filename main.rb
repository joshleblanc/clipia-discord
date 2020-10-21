require 'discordrb'
require 'rest-client'
require 'time'
require 'dotenv/load'

CLIPIA_KEY = ENV['clipia_key']
BASE_URL = "http://localhost:3000"

bot = Discordrb::Bot.new(token: ENV['token'])

bot.message do |e|
    match = e.message.to_s.match(/https:\/\/clipia\.ca\/media\/(\d+)\/?/)
    next unless match
    id = match[1]
    response = RestClient.get("#{BASE_URL}/api/v1/media/#{id}", {
        Authorization: "Bearer #{CLIPIA_KEY}"
    })
    json = JSON.parse(response.body)
    p json
    embed = Discordrb::Webhooks::Embed.new(
        title: json['title'], 
        url: "#{BASE_URL}#{json['url']}", 
        timestamp: Time.parse(json['created_at']),
        description: json['description'],
        thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: json['thumbnail_url']),
        author: Discordrb::Webhooks::EmbedAuthor.new(name: json['author']),
        footer: Discordrb::Webhooks::EmbedFooter.new(text: "#{json['views']} views")
    )

   e.respond nil, false, embed
end

bot.run