#
# Cookbook:: spring_app
# Recipe:: default
#

# 0) Instalar Java 17 
package %w(openjdk-17-jdk unzip curl git)
package %w(gradle maven default-jdk) do
  action :remove
end

app_src = "/ca2/rest"
app_dir = "/home/vagrant/spring_app"

# 1) Criar diretório da aplicação
directory app_dir do
  owner "vagrant"
  group "vagrant"
  mode "0755"
  recursive true
  action :create
end

# 2) Copiar código da aplicação 
bash "copy_spring_app_source" do
  code <<-EOH
    rm -rf #{app_dir}/*
    cp -r #{app_src}/* #{app_dir}/
  EOH
  only_if { ::File.directory?(app_src) }
end

# 3) Garantir gradlew executável
file "#{app_dir}/gradlew" do
  mode "0755"
  only_if { ::File.exist?("#{app_dir}/gradlew") }
end

# 4) Forçar Gradle a usar Java 17 
file "#{app_dir}/gradle.properties" do
  content "org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64\n"
  owner "vagrant"
  group "vagrant"
  mode "0644"
end

# 5) Fazer build usando gradlew sempre
bash "build_app" do
  cwd app_dir
  code <<-EOH
    set -e
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    ./gradlew --no-daemon clean bootJar
  EOH
end

# 6) Encontrar o JAR gerado
ruby_block "find_app_jar" do
  block do
    jar = Dir["#{app_dir}/build/libs/*.jar"].first
    raise "JAR não encontrado!" unless jar
    node.run_state["app_jar"] = jar
  end
end

# 7) Symlink estável app.jar
link "#{app_dir}/app.jar" do
  to lazy { node.run_state["app_jar"] }
end

# 8) Criar o serviço systemd
file "/etc/systemd/system/app.service" do
  content <<-EOF
[Unit]
Description=Spring Boot App
After=network.target

[Service]
User=vagrant
WorkingDirectory=#{app_dir}
ExecStart=/usr/bin/java -jar #{app_dir}/app.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
  mode "0644"
end

# 9) Ativar e arrancar serviço
service "app" do
  action [:enable, :restart]
end

# 10) Health-check leve
bash "health_check" do
  code <<-EOH
    sleep 5
    curl -I http://localhost:8080 || echo 'App não responde.'
  EOH
end
