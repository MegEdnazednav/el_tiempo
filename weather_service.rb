class WeatherService

  require 'rest-client'
  require 'nokogiri'

  TYPES = { min: "Minimum Temperature",
            max: "Maximum Temperature",
            wind: "Wind",
            weather: "Weather Symbol" }.freeze

  DIVISION = 102 #for only the cities in the province of Barcelona

  def get_location_ids(location_name)
    location_file = RestClient.get "http://api.tiempo.com/index.php?api_lang=en&division=#{DIVISION}&affiliate_id=1f95bxk4cjbu"
    xml_location_file = Nokogiri::XML(location_file)
    location_ids = []
    xml_location_file.search('//name').each do |name|
      if (name.text.include? location_name)
        location_ids << [ name['id'].to_i, name.text ]
      end
    end
    return location_ids
  end

  def get_today_weather(location)
    xml_file = RestClient.get "http://api.tiempo.com/index.php?api_lang=en&localidad=#{location}&affiliate_id=1f95bxk4cjbu"
    return {
      min: extract_weather_parameters(xml_file, TYPES[:min])[0],
      max: extract_weather_parameters(xml_file, TYPES[:max])[0],
      wind: extract_weather_parameters(xml_file, TYPES[:wind])[0],
      weather: extract_weather_parameters(xml_file, TYPES[:weather])[0]
    }
  end

  def get_average_temperature(type, location)
    xml_file = RestClient.get "http://api.tiempo.com/index.php?api_lang=en&localidad=#{location}&affiliate_id=1f95bxk4cjbu"
    weekly_temperatures = extract_weather_parameters(xml_file, TYPES[type]).map(&:to_i)
    return {
      type: TYPES[type].downcase,
      temperature: calculate_average(weekly_temperatures)
    }
  end

  private

  def extract_weather_parameters(xml_file, type)
    usable_file = Nokogiri::XML(xml_file)
    values = []
    usable_file.search('//name').each do |name|
      if type == name.text
        name.parent.xpath('data/forecast').map{ |data| values << data['value'] }
      end
    end
    return values
  end

  def calculate_average(values)
    (values.reduce(:+) / values.length).to_i
  end
end

