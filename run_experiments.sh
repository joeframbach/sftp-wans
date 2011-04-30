mkdir -p client_dir
mkdir -p server_dir
dd if=/dev/urandom of=server_dir/1k bs=1024 count=1
dd if=/dev/urandom of=server_dir/10k bs=1024 count=10
dd if=/dev/urandom of=server_dir/100k bs=1024 count=100

experiments/frame_size_perfect.rb | ./run_client.rb config.yml > results/frame_size_perfect &
experiments/frame_size_unreliable.rb | ./run_client.rb config.yml > results/frame_size_unreliable &
experiments/window_size_perfect.rb | ./run_client.rb config.yml > results/window_size_perfect &
experiments/window_size_unreliable.rb | ./run_client.rb config.yml > results/window_size_unreliable &
