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
require 'sequel'
require 'pg'

# # DATABASE CRAP
# # Connect to Harvist DB for Parameters
# db = Sequel.postgres(ENV['DATABASE_NAME'],
#                      user: ENV['DATABASE_USER'],
#                      password: ENV['DATABASE_PASSWORD'],
#                      host: ENV['DATABASE_HOST'],
#                      port: 5432)



# # Retrieve 'current' events for this type
# # Retrieve points or area of intersection




# Open, Load geoJSON
geo_json_zone_file = ARGV[0]
public_zones = JSON.parse(File.read(geo_json_zone_file))

# Ping NWS CA Weather Warnings
xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))

entries = xml_doc.css("entry")

updated = xml_doc.css("feed updated")[0].text

# Format Weather Warnings, Merge with Public Zone Polygons
weather_warning_payload = payload_generator(public_zones, entries)


# For viewing payload
for event in weather_warning_payload['feature_data']
  puts event['popup_title']
end

# # For testing payload size:
# output = open(ARGV[1], 'w')
# output.write(weather_warning_payload.to_json)




# # NEED TO ADD LAYER TO DB


# # NEED TO UPDATE CURRENT/HISTORICAL EVENTS IN DB






# # RABBITMQ CRAP, ALERT HARVIST
# # Start RabbitMQ, Publish Payload (Just message for now)
# # Need to set ENV variable for rabbitmq url
# rabbitmq_connection = BunnyEmitter.new(ENV['RABBITMQ_URL'], "nws_hazards")

# rabbitmq_connection.publish("NWS Hazards Updated!!")

# puts "Starting update loop"

# begin
#   # Then loop
#   while true

#     sleep 10

#     puts "Checking for new updates"

#     new_xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))
#     new_entries = new_xml_doc.css("feed")
#     new_updated = new_xml_doc.css("feed updated")[0].text

#     if updated == new_updated

#       puts "No change in weather alerts"
#       rabbitmq_connection.publish("No Change")

#     else    

#       puts "Change detected, pushing new alerts"

#       weather_warning_payload = payload_generator(public_zones, new_entries)  

#       rabbitmq_connection.publish("Change!!!!!")
      
#       # !!!!!!Push new payload 

#     end

#   end
# rescue Interrupt => _

#   rabbitmq_connection.close

#   exit(0)

# end