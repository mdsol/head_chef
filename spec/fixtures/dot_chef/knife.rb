# Knife.rb for chef-zero
node_name "head_chef"
chef_server_url "http://localhost:6267"
client_key File.join(File.dirname(__FILE__), "head_chef.pem")
