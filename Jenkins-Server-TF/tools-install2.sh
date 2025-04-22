#!/bin/bash
# For Ubuntu 22.04
# Intsalling Java
sudo apt update -y
sudo apt install openjdk-21-jre -y
sudo apt install openjdk-21-jdk -y
java --version

# Installing Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

# Desactivar el setup wizard
systemctl stop jenkins
sed -i 's|JAVA_ARGS=""|JAVA_ARGS="-Djenkins.install.runSetupWizard=false"|' /etc/default/jenkins

# Crear directorio para scripts Groovy
mkdir -p /var/lib/jenkins/init.groovy.d

# Crear usuario admin
tee /var/lib/jenkins/init.groovy.d/01-admin.groovy > /dev/null <<EOF
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', 'admin123')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

# Script para instalar plugins automáticamente
tee /var/lib/jenkins/init.groovy.d/02-plugins.groovy > /dev/null <<'EOF'
import jenkins.model.*

def pluginManager = Jenkins.instance.pluginManager
def uc = Jenkins.instance.updateCenter

Jenkins.instance.updateCenter.updateAllSites()

def plugins = [
  'aws-credentials',
  'pipeline-aws',
  'docker-plugin',
  'docker-commons',
  'docker-workflow',
  'docker-java-api',
  'docker-build-step',
  'adoptopenjdk',
  'nodejs',
  'dependency-check-jenkins-plugin',
  'sonar',
  'configuration-as-code'
]

plugins.each { plugin ->
  if (!pluginManager.getPlugin(plugin)) {
    def installation = uc.getPlugin(plugin)
    if (installation) {
      println("Instalando plugin: ${plugin}")
      installation.deploy()
    } else {
      println("Plugin no encontrado: ${plugin}")
    }
  } else {
    println("Plugin ya instalado: ${plugin}")
  }
}
EOF

# Asegurar permisos para Jenkins
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d

# Iniciar Jenkins
systemctl start jenkins

# Esperar a que Jenkins esté listo (puerto 8080 respondiendo)
echo "Esperando que Jenkins inicie completamente..."
until curl -s http://localhost:8080 > /dev/null; do
  sleep 10
done

# Installing Docker 
#!/bin/bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock

# If you don't want to install Jenkins, you can create a container of Jenkins
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-container jenkins/jenkins:lts

# Run Docker Container of Sonarqube
#!/bin/bash
docker run -d  --name sonar -p 9000:9000 sonarqube:lts-community


# Installing AWS CLI
#!/bin/bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Installing Kubectl
#!/bin/bash
sudo apt update
sudo apt install curl -y
sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Installing Terraform
#!/bin/bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y

# Installing Trivy
#!/bin/bash
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install trivy -y

# Installing JQ
#!/bin/bash
sudo apt install jq -y