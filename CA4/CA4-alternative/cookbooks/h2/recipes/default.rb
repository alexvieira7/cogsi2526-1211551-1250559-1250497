#
# Cookbook:: h2
# Recipe:: default
#

# Instala Java e unzip
package 'default-jre-headless'
package 'unzip'

# Cria a pasta /opt/h2
directory '/opt/h2' do
  recursive true
  action :create
end

# Copia o H2 do cookbook local
cookbook_file '/opt/h2/h2-2025-09-22.zip' do
  source 'h2-2025-09-22.zip'
  action :create
end

# Descompacta o H2
bash 'unzip_h2' do
  cwd '/opt/h2'
  code <<-EOH
    unzip -o h2-2025-09-22.zip
  EOH
  not_if { ::File.exist?('/opt/h2/h2/bin/h2.sh') }
end

# Executa o servidor H2
bash 'run_h2' do
  cwd '/opt/h2/h2/bin'
  code <<-EOH
    nohup java -cp ../lib/h2*.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -web -webAllowOthers -webPort 8082 &
  EOH
  not_if "pgrep -f org.h2.tools.Server"
end
