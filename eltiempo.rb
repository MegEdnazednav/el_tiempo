require_relative "./weather_parser"

class ReportsController

  def initialize(report_type, location_name, weather_parser)
    @report_type = report_type
    @location_name = location_name
    @weather_parser = weather_parser
  end

  def call
    location_ids = weather_service.get_location_ids(location_name)
    location = get_right_location(location_ids)
    present_answer(location)
  end
  def get_right_location(ids)
    if ids.length == 0
      p "We don't have weather info about this location"
      exit
    elsif ids.length > 1
      ids.each_with_index do |id, index|
        puts "#{index + 1} - #{id[1]}"
      end
      user_choice = STDIN.gets.chomp.to_i - 1
      return ids[user_choice]
    else
      return ids[0]
    end
  end
    case report_type
    when "-today"
      p weather_parser.get_today_weather(location_id)
    when "-av_max"
      answer = weather_parser.get_average_temperature("max", location_id)
      p "This week's average #{answer[:type]} in #{location_name} is #{answer[:temperature]}°C"
    when "-av_min"
      answer = weather_parser.get_average_temperature("min", location_id)
      p "This week's average #{answer[:type]} in #{location_name} is #{answer[:temperature]}°C"
    end
  end

  private

  attr_reader :report_type, :location_name, :weather_parser
end

parser = ReportsController.new(ARGV[0], ARGV[1], WeatherParser.new)
parser.call
