#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'ping_nws_warnings'
require 'rabbitmq'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'rgeo/geo_json'
require 'rgeo'
require 'bunny'

# Open, Load geoJSON
geo_json_zone_file = ARGV[0]
public_zones = JSON.parse(File.read(geo_json_zone_file))

# Ping NWS CA Weather Warnings
xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))

entries = xml_doc.css("entry")

updated = xml_doc.css("feed updated")[0].text

# Format Weather Warnings, Merge with Public Zone Polygons
weather_warning_payload = payload_generator(public_zones, entries)

# Start RabbitMQ, Publish Payload
rabbitmq_connection = BunnyEmitter.new("amqp://rabbitmq_server_4", "nws_hazards")

rabbitmq_connection.publish("NWS Hazards Updated!!")


# # For testing payload size:
# output = open(ARGV[1], 'w')
# output.write(weather_warning_payload.to_json)

puts "Starting update loop"

begin
  # Then loop
  while true

    sleep 10

    puts "Checking for new updates"

    new_xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))
    new_entries = new_xml_doc.css("feed")
    new_updated = new_xml_doc.css("feed updated")[0].text

    if updated == new_updated

      puts "No change in weather alerts"
      rabbitmq_connection.publish("No Change")

    else    

      puts "Change detected, pushing new alerts"

      weather_warning_payload = payload_generator(public_zones, new_entries)  

      rabbitmq_connection.publish("Change!!!!!")
      
      # !!!!!!Push new payload 

    end

  end
rescue Interrupt => _

  rabbitmq_connection.close

  exit(0)

end