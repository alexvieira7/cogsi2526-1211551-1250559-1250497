#
# Cookbook:: pam
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
package 'libpam-cracklib'

file '/etc/security/pwquality.conf' do
  content <<-EOF
minlen = 8
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
EOF
  owner 'root'
  group 'root'
  mode '0644'
end
