#!/usr/bin/env ruby

# perfect transmission (baseline)
# window size is const 8.
# frame size is variable.
# frame size 128:
# 1k file requires 8 frames, 1 window.
# 10k file requires 80 frames, 10 windows.
# 100k file requires 800 frames, 100 windows.
# frame size 512:
# 1k file requires 2 frames, 1 window.
# 10k file requires 20 frames, 4 windows.
# 100k file requires 200 frames, 40 windows.
# window size 1024:
# 1k file requires 1 frame, 1 window.
# 10k file requires 10 frames, 2 windows.
# 100k file requires 100 frames, 13 windows.

config = <<HEREDOC
config window_size 8
config error_rate 0.0
config drop_rate 0.0
config ack_drop_rate 0.0
config timeout 0.2
HEREDOC

profiles = ["
config implementation selective_repeat
config frame_size 128
","
config implementation selective_repeat
config frame_size 512
","
config implementation selective_repeat
config frame_size 1024
","
config implementation go_back
config frame_size 128
","
config implementation go_back
config frame_size 512
","
config implementation go_back
config frame_size 1024
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
