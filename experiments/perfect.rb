config = <<HEREDOC
config implementation go_back
config error_rate 0.0
config drop_rate 0.0
config ack_drop_rate 0.0
config timeout 0.2
HEREDOC

profiles = [
"config window_size 8
config frame_size 512",
"config window_size 24
config frame_size 2048"
]

# Test Commands
commands  = [
"get 1k",
"get 10k",
"get 100k"
]

puts <<HEREDOC
open frambach_server
rcd server_dir
lcd client_dir
#{config}
HEREDOC

profiles.each do |profile|
  puts profile

commands.each do |command|
  puts "config"
  6.times do
    puts "clear_stats"
    puts command
    puts "stat"
  end
end #command

end #profile

puts "close"
puts "bye"
