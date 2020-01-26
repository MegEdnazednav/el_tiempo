#!/usr/bin/env ruby
require_relative "./weather_service"

class ReportsController

  def initialize(weather_service)
    @weather_service = weather_service
  end

  def call(arguments)
    check_if_arguments_correct(arguments)
    location_ids = weather_service.get_location_ids(arguments[1])
    location = get_right_location(location_ids)
    present_answer(arguments[0], location)
  end

  private

  attr_reader :weather_service

  def check_if_arguments_correct(arguments)
    command_possibilities = [ "-av_min", "-av_max", "-today"]
    if arguments.length != 2
      p "Please enter two arguments"
      exit
    elsif !command_possibilities.include?(arguments[0])
      p "Please use a command from the list: #{command_possibilities.join(", ")}"
      exit
    end
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

  def present_answer(report_type, location)
    case report_type
    when "-today"
      answer = weather_service.get_today_weather(location[0])
      p "Today's minimum in #{location[1]} is #{answer[:min]}°C, while the maximum is #{answer[:max]}°C"
      p "There is a #{answer[:wind]} and #{answer[:weather]}"
    when "-av_max"
      answer = weather_service.get_average_temperature(:max, location[0])
      p "This week's average #{answer[:type]} in #{location[1]} is #{answer[:temperature]}°C"
    when "-av_min"
      answer = weather_service.get_average_temperature(:min, location[0])
      p "This week's average #{answer[:type]} in #{location[1]} is #{answer[:temperature]}°C"
    end
  end
end

ReportsController.new(WeatherService.new).call(ARGV)
