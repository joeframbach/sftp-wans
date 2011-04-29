## Experiments

# Server-side variables
implementations = ["selective_repeat", "go_back"]
window_sizes = [8, 24]
frame_sizes = [512, 2048]
timeouts = [0.1, 0.8]

# DataConnection variables
error_rates = [0.0, 0.2, 0.6]
drop_rates = [0.0, 0.2, 0.6]
ack_drop_rates = [0.0, 0.4]

# Test Commands
commands  = [
"put kc",
"get ks",
"put mc",
"get ms"
]

numruns = 10

puts "open frambach_server"
puts "rcd server_dir"
puts "lcd client_dir"

implementations.each do |implementation|
  puts "config implementation #{implementation}"

window_sizes.each do |window_size|
  puts "config window_size #{window_size}"

frame_sizes.each do |frame_size|
  puts "config frame_size #{frame_size}"

timeouts.each do |timeout|
  puts "config timeout #{timeout}"

error_rates.each do |error_rate|
  puts "config error_rate #{error_rate}"

drop_rates.each do |drop_rate|
  puts "config drop_rate #{drop_rate}"

ack_drop_rates.each do |ack_drop_rate|
  puts "config ack_drop_rate #{ack_drop_rate}"

commands.each do |command|
  puts "config"
  numruns.times do
    puts "clear_stats"
    puts command
    puts "stat"
  end
end #command

end #ack_drop_rate
end #drop_rate
end #error_rate
end #timeout
end #frame_size
end #window_size
end #implementation

puts "close"
puts "bye"
