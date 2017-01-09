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

begin

  # Open, Load geoJSON
  geo_json_zone_file = ARGV[0]
  public_zones = JSON.parse(File.read(geo_json_zone_file))

  # Connect to RabbitMQ
  # rabbitmq_connection = BunnyEmitter.new(ENV['RABBITMQ_URL'], "nws_hazards")


  # # DATABASE CRAP
  # # Connect to Harvist DB for Parameters
  # db = Sequel.postgres(ENV['DATABASE_NAME'],
  #                      user: ENV['DATABASE_USER'],
  #                      password: ENV['DATABASE_PASSWORD'],
  #                      host: ENV['DATABASE_HOST'],
  #                      port: 5432)



  # # Retrieve 'current' events for this type
  # # Retrieve points or area of intersection



  # CHECK HARVSIT DB FOR WEATHER HAZARDS LAYER UPDATED_AT
  # IF NIL or DIFFERENT, ADD INITIAL DATA

  puts "Getting Initial NWS Warnings"

  # Ping NWS CA Weather Warnings
  xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))

  entries = xml_doc.css("entry")

  updated = xml_doc.css("feed updated")[0].text



  # Format Weather Warnings, Merge with Public Zone Polygons, Generate Layer
  layer_output = layer_generator(public_zones, entries)


  # # # Creates hash for adding to the External Events Tables
  # # external_events_output = ext_event_creator(entries, device_groups)



  # # For viewing layer
  # for event in weather_warning_payload['feature_data']
  #   puts event['popup_title']
  # end

  # # For testing layer size:
  # output = open(ARGV[1], 'w')
  # output.write(weather_warning_payload.to_json)



  # ADD EVERYTHING TO DB

  # SEND RABBITMQ MESSAGE
  # rabbitmq_connection.publish("NWS Hazards Updated")



  # THEN LOOP

  while true

    sleep 20

    puts "Checking for NWS Warnings Update"

    new_xml_doc = Nokogiri::XML(open("https://alerts.weather.gov/cap/ca.php?x=0"))
    new_entries = new_xml_doc.css("feed")
    new_updated = new_xml_doc.css("feed updated")[0].text

    if updated != new_updated 

      puts "Change detected"

      layer_output = payload_generator(public_zones, new_entries)  
  
      # external_events_output = ext_event_creator(entries, device_groups)

      # ADD TO DATABASE

      # # SEND RABBITMQ MESSAGE
      # rabbitmq_connection.publish("NWS Hazards Updated")

      updated = new_updated

    else

      puts "No Change"

    end

  end

rescue Interrupt => _

  # # Disconnect from Rabbit
  # rabbitmq_connection.close

  # DISCONNECT FROM DATABASE

  exit(0)

end