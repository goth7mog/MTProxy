execute 'apt_update' do
  command 'apt-get update'
end

package ['apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common'] do
  action :install
end

execute 'add_docker_gpg' do
  command 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'
  not_if 'apt-key list | grep Docker'
end

execute 'add_docker_repo' do
  command 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
  not_if 'grep docker /etc/apt/sources.list /etc/apt/sources.list.d/*'
end

execute 'apt_update_docker' do
  command 'apt-get update'
end

package 'docker-ce' do
  action :install
end

execute 'add_ubuntu_to_docker' do
  command 'usermod -aG docker ubuntu'
  only_if 'id -u ubuntu'
end

execute 'install_docker_compose' do
  command 'curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
  not_if { ::File.exist?('/usr/local/bin/docker-compose') }
end


file '/usr/local/bin/docker-compose' do
  mode '0755'
end


# Copy docker-compose-mtproxy.yml to /home/ubuntu/app/docker-compose.yml
remote_file '/home/ubuntu/app/docker-compose.yml' do
  source '/root/docker-compose-mtproxy.yml'
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
  action :create
end

# Copy .env file to /home/ubuntu/app/.env
remote_file '/home/ubuntu/app/.env' do
  source '/root/.env'
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
  action :create
end

# Run 'docker-compose up' in /home/ubuntu/app
execute 'docker_compose_up' do
  command 'docker-compose up -d'
  cwd '/home/ubuntu/app'
  user 'ubuntu'
  environment ({'HOME' => '/home/ubuntu'})
end
