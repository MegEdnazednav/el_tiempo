#!/usr/bin/env ruby
class WeatherParser

  require 'rest-client'
  require 'nokogiri'
  require 'byebug'

  TYPES = { min: "Minimum Temperature",
            max: "Maximum Temperature" }.freeze

  def initialize(report_type, location_name)
    @report_type = report_type
    @location_name = location_name
  end

  def call
    set_location
    case report_type
    when "-today"
      set_today_weather
    when "-av_max"
      set_average_temperature("max")
    when "-av_min"
      set_average_temperature("min")
    end
  end

  private

  attr_reader :report_type, :location_name, :location_id, :average

  def set_location
    location_file = RestClient.get 'http://api.tiempo.com/index.php?api_lang=en&division=102&affiliate_id=1f95bxk4cjbu'
    xml_location_file = Nokogiri::XML(location_file)

    xml_location_file.search('//name').each do |name|
      if (name.text == location_name)
        @location_id = name['id'].to_i
      end
    end
  end

  def set_average_temperature(type)
    average_file = RestClient.get "http://api.tiempo.com/index.php?api_lang=en&localidad=#{location_id}&affiliate_id=1f95bxk4cjbu"
    xml_average_file = Nokogiri::XML(average_file)
    xml_average_file.search('//name').each do |name|
      if (name.text == TYPES[type.to_sym])
        calculate_average(name)
      end
    end
    p "This week's average #{TYPES[type.to_sym].downcase} in #{location_name} is #{average}°C"
  end

  def calculate_average(name)
    average = []
    name.parent.xpath('data/forecast').map{ |data| average << data['value'].to_i }
    @average = (average.reduce(:+) / average.length).to_i
  end

  def set_today_weather
    today_file = RestClient.get "http://api.tiempo.com/index.php?api_lang=en&localidad=#{location_id}&affiliate_id=1f95bxk4cjbu"
    xml_today_file = Nokogiri::XML(today_file)

    xml_today_file.search('//name').each do |name|
      case name.text
      when "Weather Symbol"
        puts name.parent.xpath('data/forecast')[0]['value']
      when "Wind"
        puts name.parent.xpath('data/forecast')[0]['value']
      end
    end
  end
end

parser = WeatherParser.new(ARGV[0], ARGV[1])
parser.call
