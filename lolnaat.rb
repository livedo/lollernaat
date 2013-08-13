#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'flowdock'
require 'json'


menu_fetchers = {
  "Amanda Bistro" => lambda do
    Nokogiri::HTML(open("http://www.amandabistro.fi/fi/lounas/")).css(".sisaltowrapper > div > h3 > font > strong")
  end,
  "Fabian" => lambda do
    Nokogiri::HTML(open("http://www.kellarikrouvi.fi/lounas/fabian")).css(".mainText p")
  end,
  "Grotesk" => lambda do
    Nokogiri::HTML(open("http://www.grotesk.fi/lounas-2/")).css("article > div")
  end,
  "Katsomo" => lambda do
    Nokogiri::HTML(open("http://www.ravintolakatsomo.fi/lounas-2")).css(".newsText table")
  end,
  "Latva" => lambda do
    Nokogiri::HTML(open("http://www.juuri.fi/")).css(".nostowrap").select {|doc| doc.text =~ /Korkeavuorenkatu/ }.first
  end,
  "Sundmans Krog" => lambda do
    Nokogiri::HTML(open("http://www.sundmans.fi/lounas/sundmans-krog")).css(".mainText td > p")
  end
}



env = File.open("./.env") { |f| YAML.load(f) }
today = Time.now.strftime("%w")
quit 0 if [0,6].include?(today.to_i)


lunchmenu = menu_fetchers.map do |heading, fetcher|
  "<h1>#{heading}</h1>#{fetcher.call.to_s.encode("utf-8")}<br><br>"
end.join(" ")


Flowdock::FLOWDOCK_API_URL = env["flowdock_endpoint"] if env["flowdock_endpoint"]

flow = Flowdock::Flow.new(
  :api_token => env["flowdock_api_token"],
  :source => "Lounasmaatti",
  :from => {
    :name => "Lolnaat",
    :address => env["from_address"]
  },
  :external_user_name => "Lounasmaatti"
)

# send message to the flow
flow.push_to_team_inbox(:subject => "Lounas tänään",
                  :link => "http://lounaat.info/unioninkatu-18-helsinki",
                  :content => lunchmenu.to_s,
                  :tags => ["lolnaat"])


# Randomly post something to chat to draw attention
sleep 4
comments = ["aikamoiset lolnaat", "huhhuh, onneks ei oo happokalaa",
  "taitaa olla kaljapäivä!", "taitaa olla burgeripäivä", "oisko vegemesta?",
  "LOUNAS!", "omnomnomnom tofuburgerii",
  "toivottavasti o rokkikokki, muuten syön pelkkää kaljaa!",
  "otettaisko appelsiiniankka uusiks?"
]
flow.push_to_chat(:content => comments[rand(comments.length)], :tags => "")



