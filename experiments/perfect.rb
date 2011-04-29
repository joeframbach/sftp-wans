config = <<HEREDOC
config implementation go_back
config error_rate 0.0
config drop_rate 0.0
config ack_drop_rate 0.0
config timeout 0.2
HEREDOC

window_sizes = [8, 24]
frame_sizes = [512, 2048]

# Test Commands
commands  = [
"get 1k",
"get 10k"
"get 100k"
]

puts <<HEREDOC
open frambach_server
rcd server_dir
lcd client_dir
#{config}
config
HEREDOC

window_sizes.each do |window_size|
  puts "config window_size #{window_size}"

frame_sizes.each do |frame_size|
  puts "config frame_size #{frame_size}"

commands.each do |command|
  6.times do
    puts "clear_stats"
    puts command
    puts "stat"
  end
end #command

end #frame_size
end #window_size

puts "close"
puts "bye"
