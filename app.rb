require_relative 'app/rubycal/rubycal'
require 'chronic'

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

$events_parser = Proc.new { |name, events|
  puts "#{name}"
  puts "--------------------"
  events.each &$event_parser
  puts
}

$event_parser = Proc.new { |event|
  event.each do |k, v| 
    if v.instance_of? Time
      puts " -> #{k}: #{v.strftime("%b %e, %Y at %I:%M %p")}"
    else
      puts " -> #{k}: #{v}" 
    end
  end
}

loop do
  unless $init
    puts "\nWelcome to RubyCal, the number one choice for non-GUI connoisseurs"
    puts
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
      loop do 
        puts "\nWhat would you like the calendar to be called?"
        name = gets.chomp
        begin
          break if name == "-cancel"
          $app.add_cal(name)
          puts "\nAdded #{name} to your calendars!"
          break
        rescue => exception
          puts exception
        end
      end

    when "use"
      unless $app.get_cals.length > 0
        puts "No calendars added yet!"
      else
        loop do
          puts "Which calendar would you like to use?"
          puts "\nYour available calendars are:"
          $app.get_cals.each { |name| puts "  #{name}" }
          name = gets.chomp
          begin
            break if name == "-cancel"
            $app.use_cal(name)
            break puts "Now using calendar #{name}"
          rescue => exception
            puts exception
          end
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

        puts "Event name? (required)"
        name = gets.chomp
        puts "Start time? (required)"
        start_time = gets.chomp
        puts "End time? You may also use 'all-day'"
        end_time = gets.chomp
        puts "Locationstub"

        $app.add_event({
          name: name,
          start_time: Chronic.parse(start_time),
          end_time: end_time == 'all-day' ? nil : Chronic.parse(end_time),
          all_day: end_time == 'all-day'
        })
        puts "Added #{name} to #{$app.calendar.name}"
      rescue => exception
        puts exception
      end

    when "get"
      begin
        raise "Set a calendar first!" unless $app.calendar

        puts "Choose an option to search by:"
        puts "  all    -   all events"
        puts "  name   -   by name"
        puts "  today  -   by today"
        puts "  date   -   by date"
        puts "  week   -   within the next week"

        param = gets.chomp
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
        end

      rescue => exception
        puts exception
      end

    when "update"
      # begin
      #   raise "Set a calendar first!" unless $app.calendar

      #   loop do

      #     puts "Which event would you like to update? (name)"
      #     name = gets.chomp
      #     break if name == '-cancel'

      #     puts "New name? ('-no' if the same)"
      #     update_name = gets.chomp
      #     break if update_name == '-cancel'

      #     puts "New start time? ('-no' if the same)"
      #     update_start_time = gets.chomp
      #     break if update_start_time == '-cancel'

      #     puts "New end time? ('-no' if the same, 'all-day' if you want to switch)"
      #     update_end_time = gets.chomp
      #     break if update_end_time == '-cancel'

      #     puts "location stub"

      #     update_params = {}
      #     update_params[:name] = update_name unless update_name == '-no'
      #     update_params[:start_time] = Chronic.parse(update_start_time) unless update_start_time == '-no'
      #     if (update_end_time == 'all-day')
      #       update_params[:all_day] = true

      #     update_params[:end_time] = Chronic.parse(u)
      #     update_params[:end_time] = Chronic.parse(update_end_time)
      #   end
      # rescue => exception
      #   puts exception.message
      # end

    when "remove"
      begin
        puts "Which event(s) would you like to remove?"
        puts "Available events for #{$app.calendar.name}:"
        $app.get_events.each { |name, events| puts "  #{name}"}
        param = gets.chomp
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
