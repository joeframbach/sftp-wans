#!/usr/bin/env ruby

# perfect transmission (baseline)
# frame size is const 256.
# 1k file will send 4 frames, 10k 40, 100k 400.
# window size is variable.
# window size 4:
# 1k file requires 1 window.
# 10k file requires 10 windows.
# 100k file requires 100 windows.
# window size 8:
# 1k file requires 1 window.
# 10k file requires 5 windows.
# 100k file requires 50 windows.
# window size 16:
# 1k file requires 1 window.
# 10k file requires 3 windows.
# 100k file requires 25 windows.

config = <<HEREDOC
config frame_size 256
config error_rate 0.0
config drop_rate 0.0
config ack_drop_rate 0.0
config timeout 0.2
HEREDOC

profiles = ["
config implementation selective_repeat
config window_size 4
","
config implementation selective_repeat
config window_size 8
","
config implementation selective_repeat
config window_size 16
","
config implementation go_back
config window_size 4
","
config implementation go_back
config window_size 8
","
config implementation go_back
config window_size 16
"]

# Test Commands
commands  = [
"get 1k",
"get 10k",
"get 100k"
]

puts <<HEREDOC
open demo_server
rcd server_dir
lcd client_dir
#{config}
HEREDOC

profiles.each do |profile|
  puts profile

commands.each do |command|
  puts "config"
  puts "clear_stats"
  puts command
  puts "stat"
end #command

end #profile

puts "close"
puts "bye"
