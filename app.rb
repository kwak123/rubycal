require_relative 'app/rubycal/rubycal'
require 'chronic'
require 'street_address'

$app = RubyCal::App.new
$init = false

$commands = Proc.new {
  puts "\n(Any parameter prefixed with a ? is optional)"
  puts "  start    -   Add a new calendar"
  puts "  use      -   Switches to the desired calendar"
  puts "  cal      -   Returns all available calendars"
  puts "  add      -   Start up a command chain for adding a new event"
  puts "  get      -   Fetches all events, by specific params if desired."
  puts "  update   -   Start up a command chain for updating events"
  puts "  remove   -   Removes any events matching the event name"
  puts "  -cancel  -   Use at any time to back out of the current chain"
  puts "  -l       -   To view these commands again"
}

$search_options = Proc.new {
  puts "Choose an option to search by:"
  puts "  all    -   all events"
  puts "  name   -   by name"
  puts "  today  -   by today"
  puts "  date   -   by date"
  puts "  week   -   within the next week"
}

$events_parser = Proc.new { |name, events|
  puts "#{name}"
  puts "--------------------"
  events.each &$event_parser
  puts
}

$event_parser = Proc.new { |event|
  event.each do |k, v|
    if v.instance_of? Time
      puts " -> #{$key_helper.call(k)}: #{v.strftime("%b %e, %Y at %I:%M %p")}"
    elsif k == :location
      puts " -> #{$key_helper.call(k)}: #{$location_helper.call(v)}"
    else
      puts " -> #{$key_helper.call(k)}: #{v}"
    end
  end
}

$key_helper = lambda { |k|
  case k
    when :start_time
      'Starts'
    when :end_time
      'Ends'
    when :location
      'Location'
    else
      k
  end
}

$location_helper = lambda { |loc|
  street = [loc[:address], loc[:city], loc[:state], loc[:zip]].compact
  "#{loc[:name]}: #{street.join(', ')}"
}

loop do
  unless $init
    puts "\nWelcome to RubyCal, the number one choice for non-GUI connoisseurs"
    puts "\nSome commands to help you get started..."
    $commands.call
    $init = true
  else
    puts "\nBack to the main menu!"
  end

  puts "What would you like to do?"
  input = gets.chomp
  command, *params = input.split /\s/

  case command
    when "start"
      begin
        if params && params[0]
          $app.add_cal(params[0])
          puts "\nAdded #{params[0]} to your calendars!"
        else
          loop do
            puts "\nWhat would you like the calendar to be called?"
            name = gets.chomp
            begin
              break if name == "-cancel"
              $app.add_cal(name)
              break puts "\nAdded #{name} to your calendars!"
            rescue => exception
              puts exception
            end
          end
        end
      rescue => exception
        puts exception
      end

    # There certainly must be a more elegant solution to this
    when "use"
      unless $app.get_cals.length > 0
        puts "No calendars added yet!"
      else
        begin
          if params && params[0]
            $app.use_cal(params[0])
            puts "Now using calendar #{params[0]}"
          else
            loop do
              begin
                puts "\nWhich calendar would you like to use?"
                puts "Your available calendars are:"
                $app.get_cals.each { |name| puts "  #{name}" }
                name = gets.chomp
                break if name == "-cancel"
                $app.use_cal(name)
                break puts "Now using calendar #{name}"
              rescue => exception
                puts exception
              end
            end
          end
        rescue => exception
          puts exception
        end
      end

    when "cal"
      unless $app.get_cals.length > 0
        puts "No calendars added yet!"
      else
        puts "\nYour available calendars are:"
        $app.get_cals.each { |name| puts "  #{name}" }
      end

    when "add"
      begin
        raise "Set a calendar first!" unless $app.calendar

        loop do
          event_params = {}

          puts "\nEvent name? (required)"
          name = gets.chomp
          break if name == '-cancel'
          event_params[:name] = name

          puts "Start time? (required)"
          start_time = Chronic.parse(gets.chomp)
          break if start_time == '-cancel'
          raise "Couldn't parse that start time" if start_time == nil
          event_params[:start_time] = start_time

          puts "End time? You may also use 'all-day'"
          end_time = gets.chomp
          break if end_time == '-cancel'

          unless end_time == 'all-day'
            end_time = Chronic.parse(end_time)
            raise "Couldn't parse that end time" if end_time == nil
          end
          event_params[:end_time] = end_time == 'all-day' ? nil : end_time
          event_params[:all_day] = end_time == 'all-day'

          puts "Would you like to add a location? (y/n)"
          wants_loc = gets.chomp

          if wants_loc == "y" || wants_loc == "yes"
            location = {}
            puts "What's the place called?"
            location[:name] = gets.chomp
            puts "Location address?"
            address = StreetAddress::US.parse(gets.chomp)
            raise "Couldn't parse that address" if address == nil
            location[:address] = "#{address.number} #{address.street} #{address.street_type}".chomp
            location[:city] = address.city
            location[:state] = address.state
            location[:zip] = address.postal_code
            event_params[:location] = location
          end

          $app.add_event(event_params)
          break puts "Added #{name} to #{$app.calendar.name}"
        end
      rescue => exception
        puts exception
      end

    when "get"
      begin
        raise "Set a calendar first!" unless $app.calendar
        param = params && params[0] ? params[0] : gets.chomp
        case param

          when "all"
            $app.get_events.each &$events_parser

          when "name"
            puts "Event name?"
            puts "Available events for #{$app.calendar.name}:"
            $app.get_events.each { |name, events| puts "  #{name}" }
            param = gets.chomp
            break if param == '-cancel'
            puts
            temp = $app.get_events_with_name(param)
            if temp.length > 0
              puts "\n#{param}"
              temp.each &$event_parser
            else
              puts "No events found with name #{param}"
            end

          when "today"
            temp = $app.get_events_for_today
            if temp.length > 0
              temp.each &$events_parser
            else
              puts "No events for today"
            end

          when "date"
            puts "What's the date?"
            param = gets.chomp
            break if param == '-cancel'
            time = Chronic.parse(param)
            temp = $app.get_events_for_date(time)
            if temp.length > 0
              temp.each &$events_parser
            else
              puts "No events found for #{time.strftime('%b %e, %Y')}"
            end

          when "week"
            $app.get_events_for_this_week.each &$events_parser

          else
            puts "#{param} is not a valid option!"
        end

      rescue => exception
        puts exception
      end

    when "update"
      begin
        raise "Set a calendar first!" unless $app.calendar

        loop do

          puts "\nWhich event would you like to update? (name)"
          puts "Available events for #{$app.calendar.name}:"
          $app.get_events.each { |name, events| puts "  #{name}"}

          name = gets.chomp
          raise "No event by that name" unless $app.get_events.has_key? name
          break if name == '-cancel'

          update_params = {}

          puts "New name? ('-no' if the same)"
          update_name = gets.chomp
          break if update_name == '-cancel'
          update_params[:name] = update_name unless update_name == '-no'

          puts "New start time? ('-no' if the same)"
          update_start_time = gets.chomp
          break if update_start_time == '-cancel'
          unless update_start_Time == '-no'
            update_start_time = Chronic.parse(update_start_time)
            raise "Couldn't parse that start time" if update_start_time == nil
            update_params[:start_time] = update_start_time
          end

          puts "New end time? ('-no' if the same, 'all-day' to mark as an all-day event)"
          update_end_time = gets.chomp
          break if update_end_time == '-cancel'
          unless update_end_time == '-no'
            if update_end_time == 'all-day'
              update_params[:end_time] == nil
              update_params[:all_day] == true
            else
              update_end_time = Chronic.parse(update_end_time)
              raise "Couldn't parse that end time" if update_end_time == nil
              update_params[:end_time] == update_end_time
              update_params[:all_day] == false
            end
          end

          location = {}
          puts "New location name? ('-no' if the same)"
          update_loc_name = gets.chomp
          break if update_loc_name = '-cancel'
          unless update_loc_name == '-no'
            location[:name] = update_loc_name
          end

          puts "New location address? ('-no' if the same)"
          update_loc_address = gets.chomp
          unless update_loc_name == 'no'
            address = StreetAddress::US.parse(gets.chomp)
            raise "Couldn't parse that address" if address == nil
            location[:address] = "#{address.number} #{address.street} #{address.street_type}".chomp
            location[:city] = address.city
            location[:state] = address.state
            location[:zip] = address.postal_code
          end

          $app.update_events(name, update_params)
          break puts "Successfully updated #{name} in #{$app.calendar.name}"
        end
      rescue => exception
        puts exception.message
      end

    when "remove"
      begin
        puts "\nWhich event(s) would you like to remove?"
        puts "Available events for #{$app.calendar.name}:"
        $app.get_events.each { |name, events| puts "  #{name}"}
        param = gets.chomp
        temp = $app.remove_events(param)
        puts "Removed #{temp == 1 ? temp.to_s + ' event' : temp.to_s + ' events'} with name #{param}"
      rescue => exception
        puts exception
      end

    when "-cancel"
      break puts "Good bye!"

    when "-l"
      $commands.call

    else
      puts "Couldn't understand that command. -l to view available commands"
  end
end
