#
# Cookbook:: healthcheck
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
file '/opt/healthcheck.sh' do
  content <<-EOH
#!/bin/bash
curl -I http://localhost:8080 > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "$(date): Aplicação não está a responder" >> /var/log/healthcheck.log
fi
EOH
  mode '0755'
  owner 'root'
  group 'root'
end

cron 'healthcheck' do
  minute '*/2'
  command '/opt/healthcheck.sh'
end
