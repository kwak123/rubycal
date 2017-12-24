require_relative 'rubycal/calendar'

class App
end


$app = App.new

loop do  
  input = gets.chomp
  command, *params = input.split /\s/
end
