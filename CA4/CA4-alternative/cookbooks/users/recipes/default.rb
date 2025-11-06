#
# Cookbook:: users
# Recipe:: default
#

# Criar grupo 'devops'
group 'devops' do
  action :create
end

# Criar grupo 'developers'
group 'developers' do
  action :create
end

# Criar utilizador 'admin' e associar ao grupo 'devops'
user 'admin' do
  comment 'Administrador do sistema'
  home '/home/admin'
  shell '/bin/bash'
  manage_home true
  gid 'devops'   
  password '$1$abc123$EXEMPLODEHASH' 
  action :create
end

# Criar utilizador 'devuser' e associar ao grupo 'developers'
user 'devuser' do
  comment 'Developer user'
  home '/home/devuser'
  shell '/bin/bash'
  manage_home true
  gid 'developers'  
  action :create
end
