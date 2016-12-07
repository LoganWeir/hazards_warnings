def payload_formatter(unformatted_payload)

  formatted_output = {}

  layer_id = 4892

  factory = RGeo::Geographic.simple_mercator_factory(:srid => 4326)

  # Build Layer
  layer_hash = {}
  layer_hash['name'] = "National Weather Service Public Alerts"
  layer_hash['id'] = layer_id

  formatted_output['layer_data'] = layer_hash

  # Build Features
  feature_array = []

  for key, value in unformatted_payload

    if value['events'].length != 0

      feature_hash = {}

      alpha_num = (('a'..'z').to_a + (0..9).to_a)
      feature_hash['feature_id'] = \
        (0..35).map { alpha_num[rand(alpha_num.length)] }.join

      feature_hash['layer_id'] = layer_id

      # Fill color is just red for now
      feature_hash['fill_color'] = "#de2d26"

      # Need to modify Harvist API to accept zoom_level = 0
      # For now, this layer will only be visible if zoomed all the way out
      feature_hash['zoom_level'] = 13

      title_description = pop_up_title_description(value['events'])

      feature_hash['popup_title'] = title_description[0]

      feature_hash['popup_description'] = title_description[1]

      rgeo_hash = RGeo::GeoJSON.decode(value['polygon'])

      feature_hash['geo_data'] = factory.collection([rgeo_hash])

      feature_array << feature_hash 

    end

  end

  formatted_output['feature_data'] = feature_array

  return formatted_output

end


# This is only temporary, much more information to display
def pop_up_title_description(event_array)

  if event_array.length == 1

    popup_title = event_array[0]['event_title']

    updated_string = "Last Updated: #{event_array[0]['updated']}"
    popup_description = updated_string

  else

    event_titles = []
    event_updates = []

    for event in event_array

      event_titles << event['event_title']
      event_updates << event['updated']

    end

    popup_title = event_titles.join(", ")
    popup_description = event_updates.join(", ")

  end

  return [popup_title, popup_description]

end




def payload_generator(public_zones, entries)

  for event in entries

    # Only Valid Events
    next unless entry_validation(event) == true

    geocodes = event.css("cap|geocode value")

    event_geocodes = geocodes[1].text.split(" ")

    for dirty_code in event_geocodes

      # Snipping out the initial 'CAZ' from the NWS Codes
      cleaned_code = dirty_code[3..-1].to_s

      # If entry code is in hash.keys
      if public_zones.keys.include?(cleaned_code)

        # Add to event to array of events associated with the polygon hash.
        public_zones[cleaned_code]['events'] << event_hash_builder(event)

      end

    end

  end

  formatted_output = payload_formatter(public_zones)

  return formatted_output

end



def entry_validation(event)

  status = event.css("cap|status").text
  msgtype = event.css("cap|msgType").text

  if status != "Actual"

    return false

  elsif (msgtype != "Alert") && (msgtype != "Update")

    return false

  else

    return true

  end
    
end


def event_hash_builder(event)

  key_tag_hash = {
    "id" => "id",
    "summary" => "summary",
    "updated" => "updated",
    "event_title" => "cap|event",
    "urgency" => "cap|urgency",
    "severity" => "cap|severity",
    "certainty" => "cap|certainty"
  }

  event_hash = {}

  for key, tag in key_tag_hash

    event_hash[key] = event.css(tag).text

  end

  # Trickier field that need some processing
  event_hash["category"] = category_cleaner(event.css("cap|category").text)

  return event_hash

end



def category_cleaner(short_category)

  nws_categories = {
    "Geo" => "Geophysical",
    "Met" => "Meteorological",
    "Safety" => "General emergency and public safety",
    "Rescue" => "Rescue and recovery",
    "Fire" => "Fire supression and rescue",
    "Health" => "Medical and public health",
    "Env" => "Pollution and other environmental",
    "Transport" => "Public and private transportation",
    "Infra" => "Utility, telecommunication, other non-transport infrastructure",
    "CBRNE" => \
      "Chemical, Biological, Radiological, Nuclear or High-Yield Explosive " + \
      "threat or attack",
    "Other" => "Other events"
  }

  if nws_categories.keys.include?(short_category)

    category = nws_categories[short_category]

  else

    category = "Unknown category: #{short_category}"

  end

  return category

end




















