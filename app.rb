require_relative 'app/rubycal/rubycal'
require 'chronic'

class App

  def initialize
    @calendars = {}
  end

  public
  def use(name)
    unless @calendars[name]
      @calendars[name] = RubyCal::Calendar.new(name)
    end
    @calendar = @calendars[name]
    puts "Switched to #{@calendar.name}"
  end

  public
  def add
    return puts "Specify a calendar to use first!" unless @calendar
    puts "Event name? (required!)"
    name = gets.chomp
    puts "Start time? (required!)"
    time = Chronic.parse(gets.chomp)
    if time
      event = RubyCal::Event.new({ name: name, start_time: time })
      @calendar.add_event(event)
      puts "Added #{name} to #{@calendar.name}"
    else
      puts "Hmm, we couldn't understand #{time}, try again"
    end
  end

  public
  def get
    return puts "Specify a calendar to use first!" unless @calendar
    loop do
      puts
      puts "Which event would you like to see?"
      puts "  -all to see all available events"
      puts "  -done to go back"
      name = gets.chomp
      case name
        when "-all"
          if @calendar.events.length > 0
            @calendar.events.each { |k, v| puts " - #{k}" }
          else
            puts "#{@calendar.name} has no events yet!"
          end
        when "-done"
          puts "Back to main menu"
          break
        else
          temp = @calendar.events_with_name(name)
          puts temp.length > 0 ? temp : "No events by that name!"
      end
    end
  end

  public
  def get_calendars
    puts "Available calendars are:"
    if @calendars.length > 0
      @calendars.each_key { |x| puts " - #{x}" }
    else
      puts " - None yet, add a new calendar!"
    end
  end
  
end

$app = App.new
$init = false

$commands = Proc.new {
  puts "(Any parameter prefixed with a ? is optional"
  puts "\t use      -   Switches to a calendar, or creates a new one if one doesn't exist yet"
  puts "\t cal      -   Returns all available calendars"
  puts "\t add      -   Start up a command chain for adding a new event"
  puts "\t update   -   Start up a command chain for updating events"
  puts "\t get      -   Fetches all events, by specific params if available. -pe to see available parameters"
  puts "\t remove   -   Removes any events matching the event name"
  puts "\t -l                  -   To view these commands again"
}

loop do
  unless $init
    puts "Welcome to RubyCal, the number one choice for non-GUI connoisseurs"
    puts
    puts "Some commands to help you get started..."
    $commands.call
    $init = true
  end

  puts
  input = gets.chomp
  command, *params = input.split /\s/

  case command
    when "use"
      if params.length
        $app.use(params[0])
      else
        puts "Which calendar would you like to use?"
        $app.get_calendars
        name = gets.chomp
        $app.use(name)
      end
    when "cal"
      $app.get_calendars
    when "add"
      $app.add
    when "get"
      $app.get
    when "-l"
      $commands.call
    else
      puts "Couldn't understand that command. -l to view available commands"
  end
end
