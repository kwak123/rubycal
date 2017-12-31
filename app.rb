require 'active_support'
require 'active_support/core_ext'
require "chronic"
require "street_address"
require "colorize"

require_relative "app/rubycal/rubycal"

$app = RubyCal::App.new
$init = false

$commands = lambda {
  puts "Commands followed by <?> support a parameter as a shortcut for the first set of options"
  puts "  start <?>   -  Add a new calendar"
  puts "  use <?>     -  Set current calendar to the desired calendar"
  puts "  cal         -  Returns all available calendars"
  puts "  add         -  Start up a command chain for adding a new event"
  puts "  get <?>     -  Fetches all events, by specific params if desired."
  puts "  update <?>  -  Start up a command chain for updating events"
  puts "  remove <?>  -  Removes any events matching the event name"
  puts "  -cancel     -  Use at any time to back out of the current chain"
  puts "  -l          -  To view these commands again"
}

$search_options = lambda{
  puts "\nChoose an option to search by:"
  puts "  all      -  all events"
  puts "  name     -  by name"
  puts "  today    -  by today"
  puts "  date     -  by date"
  puts "  week     -  within the next week"
  puts "  -cancel  -  return to main menu"
}

$search_helper = lambda { |param|
  case param
    when "all"
      $app.get_events.each &$events_parser

    when "name"
      puts "\nEvent name?"
      puts "Available events for #{$app.calendar.name}:"
      $app.get_events.each { |name, events| puts "  #{name}" }
      param = gets.chomp
      break if param == "-cancel"
      $events_parser.call(param, $app.get_events_with_name(param))

    when "today"
      $app.get_events_for_today.each &$events_parser

    when "date"
      puts "\nWhat's the date?"
      param = gets.chomp
      break if param == "-cancel"
      date = Chronic.parse(param)
      raise "Couldn't parse that date" if date == nil
      $app.get_events_for_date(date).each &$events_parser

    when "week"
      $app.get_events_for_this_week.each &$events_parser

    else
      puts "#{param} is not a valid option!"
  end
}

$update_helper = lambda {
  update_params = {}

  puts "\nNew name? ('-no' if the same)"
  update_name = gets.chomp
  break if update_name == "-cancel"
  update_params[:name] = update_name unless update_name == "-no"

  puts "New start time? ('-no' if the same)"
  update_start_time = gets.chomp
  break if update_start_time == "-cancel"
  unless update_start_time == "-no"
    update_start_time = Chronic.parse(update_start_time)
    raise "Couldn't parse that start time" if update_start_time == nil
    update_params[:start_time] = update_start_time
  end

  puts "New end time? ('-no' if the same, 'all-day' to mark as an all-day event)"
  update_end_time = gets.chomp
  break if update_end_time == "-cancel"
  unless update_end_time == "-no"
    if update_end_time == "all-day"
      update_params[:end_time] = nil
      update_params[:all_day] = true
    else
      update_end_time = Chronic.parse(update_end_time)
      raise "Couldn't parse that end time" if update_end_time == nil
      update_params[:end_time] = update_end_time
      update_params[:all_day] = false
    end
  end

  location = {}
  puts "New location name? ('-no' if the same)"
  update_loc_name = gets.chomp
  break if update_loc_name == "-cancel"
  location[:name] = update_loc_name unless update_loc_name == "-no"

  puts "New location address? ('-no' if the same)"
  update_loc_address = gets.chomp
  break if update_loc_address == "-cancel"
  $address_parser.call(update_loc_address, location) unless update_loc_address == "-no"

  update_params[:location] = location if location.length > 0
  update_params
}

$events_parser = lambda { |name, events|
  puts "\n# #{name} #".colorize(:blue)
  puts "--------------------"
  events.each &$event_parser
}

$address_parser = lambda { |new_address, location = {}|
  address = StreetAddress::US.parse(new_address)
  if address == nil
    puts "Couldn't parse that address".colorize(:red)
    puts "Would you like to input it manually? (y/n)"
    manual_input = gets.chomp
    if manual_input == 'y'
      puts "Location street? ('-no' if no street desired)"
      street = gets.chomp
      location[:address] = street.titleize unless street == '-no'
      puts "Location city? ('-no' if no city desired)"
      city = gets.chomp
      location[:city] = city.titleize unless city == '-no'
      puts "Location state? ('-no' if no state desired)"
      state = gets.chomp
      location[:state] = state.upcase unless state == '-no'
      puts "Location zip? ('-no' if no zip desired)"
      zip = gets.chomp
      location[:zip] = zip unless zip == '-no'
    end
  else
    location[:address] = "#{address.number} #{address.street} #{address.street_type}".chomp
    location[:city] = address.city
    location[:state] = address.state
    location[:zip] = address.postal_code
  end
  location
}

$event_parser = lambda { |param|
  param.each do |k, v|
    if v.instance_of? Time
      puts " -> #{$key_formatter.call(k)}: #{v.strftime("%b %-d, %Y at %I:%M %p")}"
    elsif k == :location
      puts " -> #{$key_formatter.call(k)}: #{$location_formatter.call(v)}"
    elsif k == :all_day
      puts " -> Ends: All-day"
    else
      puts " -> #{$key_formatter.call(k)}: #{v}"
    end
  end
  puts
}

$key_formatter = lambda { |k|
  case k
    when :start_time
      "Starts"
    when :end_time
      "Ends"
    when :location
      "Location"
    else
      k
  end
}

$location_formatter = lambda { |loc|
  street = [loc[:address], loc[:city], loc[:state], loc[:zip]].compact
  "#{loc[:name]}: #{street.join(', ')}"
}

# Begin the app! #
puts "\nWelcome to RubyCal, the number one choice for non-GUI connoisseurs".colorize(:blue)
puts "\nSome commands to help you get started...".colorize(:blue)
$commands.call

loop do
  puts "\nMain menu!".colorize(:blue)
  puts "What would you like to do?"
  input = gets.chomp
  command, *params = input.split /\s/

  begin
    case command
      when "start"
        if params && params[0]
          $app.add_cal(params[0])
          puts "\nAdded #{params[0]} to your calendars!".colorize(:green)
        else
          loop do
            puts "\nWhat would you like the calendar to be called?"
            name = gets.chomp
            begin
              break if name == "-cancel"
              $app.add_cal(name)
              break puts "\nAdded #{name} to your calendars!".colorize(:green)
            rescue => exception
              puts exception.to_s.colorize(:red)
            end
          end
        end

      when "use"
        raise "No calendars added yet!" unless $app.get_cals.length > 0
        if params && params[0]
          $app.use_cal(params[0])
          puts "\nNow using calendar #{params[0]}".colorize(:green)
        else
          loop do
            begin
              puts "\nWhich calendar would you like to use?"
              puts "Your available calendars are:"
              $app.get_cals.each { |name| puts "  #{name}" }
              name = gets.chomp
              break if name == "-cancel"
              $app.use_cal(name)
              break puts "\nNow using calendar #{name}".colorize(:green)
            rescue => exception
              puts exception.colorize.to_s.colorize(:red)
            end
          end
        end

      when "cal"
        raise "No calendars added yet!" unless $app.get_cals.length > 0
        puts "\nYour available calendars are:"
        $app.get_cals.each { |name| puts "  #{name}" }
        puts $app.calendar ? "\nCurrently using #{$app.calendar.name}" : "\nNo calendar currently selected"

      when "add"
        raise "Set a calendar first!" unless $app.calendar

        loop do
          event_params = {}

          puts "\nEvent name? (required)"
          name = gets.chomp
          raise "Name required!" unless name.length > 0
          break if (name == "-cancel")
          event_params[:name] = name

          puts "Start time? (required)"
          start_time = Chronic.parse(gets.chomp)
          break if start_time == "-cancel"
          raise "Couldn't parse that start time" if start_time == nil
          event_params[:start_time] = start_time

          puts "End time? You may also use 'all-day'"
          end_time = gets.chomp
          break if end_time == "-cancel"

          unless end_time == "all-day"
            end_time = Chronic.parse(end_time)
            raise "End time must be later than start time" if start_time > end_time
            raise "Couldn't parse that end time" if end_time == nil
          end
          event_params[:end_time] = end_time == "all-day" ? nil : end_time
          event_params[:all_day] = end_time == "all-day"

          puts "Would you like to add a location? (y/n)"
          wants_loc = gets.chomp

          if wants_loc == "y" || wants_loc == "yes"
            location = {}
            puts "What's the location called? (required)"
            loc_name = gets.chomp
            break if loc_name == "-cancel"
            location[:name] = loc_name
            puts "Location address? ('-no' if no address desired)"
            address = gets.chomp
            break if address == "-cancel"
            unless address == "-no"
              $address_parser.call(address, location)
              event_params[:location] = location
            end
          end

          $app.add_event(event_params)
          break puts "Added #{name} to #{$app.calendar.name}".colorize(:green)
        end

      when "get"
        raise "Set a calendar first!" unless $app.calendar
        if params && params[0]
          $search_helper.call(params[0])
        else
          puts "What would you like to get?"
          loop do
            begin
              $search_options.call
              param = gets.chomp
              break if param == "-cancel"
              break $search_helper.call(param)
            rescue => exception
              break puts exception.to_s.colorize(:red)
            end
          end
        end

      when "update"
        raise "Set a calendar first!" unless $app.calendar
        if params && params[0]
          update_params = $update_helper.call
          $app.update_events(params[0], update_params)
          puts "Successfully updated #{params[0]} in #{$app.calendar.name}".colorize(:green)
        else
          loop do
            puts "\nWhich event(s) would you like to update? (name)"
            puts "Available events for #{$app.calendar.name}:"
            $app.get_events.each { |name, events| puts "  #{name}"}

            name = gets.chomp
            break if name == "-cancel"
            raise "No event by that name" unless $app.get_events.has_key? name.to_sym

            update_params = $update_helper.call

            $app.update_events(name, update_params)
            break puts "Successfully updated #{name} in #{$app.calendar.name}".colorize(:green)
          end
        end

      when "remove"
        if params && params[0]
          temp = $app.remove_events(params[0])
          puts "Removed #{temp == 1 ? temp.to_s + " event" : temp.to_s + " events"} with name #{param}".colorize(:green)
        else
          puts "\nWhich event(s) would you like to remove?"
          puts "Available events for #{$app.calendar.name}:"
          $app.get_events.each { |name, events| puts "  #{name}"}
          param = gets.chomp
          unless param == "-cancel"
            temp = $app.remove_events(param)
            puts "Removed #{temp == 1 ? temp.to_s + " event" : temp.to_s + " events"} with name #{param}".colorize(:green)
          end
        end

      when "-cancel"
        break puts "Good bye!"

      when "-l"
        $commands.call

      else
        puts "Couldn't understand that command. -l to view available commands".colorize(:red)
    end
  rescue => exception
    puts exception.to_s.colorize(:red)
  end
end