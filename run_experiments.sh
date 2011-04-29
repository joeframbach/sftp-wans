ruby experiments/selective_repeat_experiments.rb | ./run_client.rb client_config.yml | grep "{" > results/selective_repeat_results &
ruby experiments/go_back_experiments.rb | ./run_client.rb client_config.yml | grep "{" > results/go_back_results &
