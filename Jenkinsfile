pipeline {
    agent any
 
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
 
        TF_DIR       = "terraform"
        ANSIBLE_DIR  = "ansible"
        INVENTORY    = "ansible/inventory/hosts"
 
        SSH_KEY      = "/var/lib/jenkins/.ssh/devops-key.pem"
 
        EMAIL_TO     = "r.sheshanthr@gmail.com"
    }
 
    options {
        timestamps()
    }
 
    stages {
 
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sheshanth-ramidi/devops-master-project.git'
            }
        }
 
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir("${TF_DIR}") {
                        sh '''
                          terraform init -reconfigure
                        '''
                    }
                }
            }
        }
 
        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir("${TF_DIR}") {
                        sh '''
                          terraform plan
                        '''
                    }
                }
            }
        }
 
        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir("${TF_DIR}") {
                        sh '''
                          terraform apply -auto-approve
                        '''
                    }
                }
            }
        }
 
        stage('Fetch EC2 Public IP') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        env.EC2_IP = sh(
                            script: "terraform output -raw web_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
                echo "EC2 Public IP: ${EC2_IP}"
            }
        }
 
        stage('Generate Ansible Inventory') {
            steps {
                sh "mkdir -p ${ANSIBLE_DIR}/inventory"
 
                writeFile file: "${INVENTORY}", text: """
[web]
web1 ansible_host=${EC2_IP}
 
[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=${SSH_KEY}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
"""
            }
        }
 
        stage('Prepare SSH') {
            steps {
                sh '''
                  chmod 600 /var/lib/jenkins/.ssh/devops-key.pem || true
                  ssh-keygen -R ${EC2_IP} || true
                  ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/devops-key.pem ubuntu@${EC2_IP} "echo SSH OK"
                '''
            }
        }
 
        stage('Test Ansible Connectivity') {
            steps {
                sh '''
                  ansible -i ansible/inventory/hosts web -m ping
                '''
            }
        }
 
        stage('Run Ansible Playbook') {
            steps {
                sh '''
                  ansible-playbook -i ansible/inventory/hosts ansible/playbooks/web.yml
                '''
            }
        }
    }
 
    post {
        success {
            mail to: "${EMAIL_TO}",
                 subject: "✅ Jenkins Pipeline SUCCESS – DevOps Master Project",
                 body: """
Pipeline executed successfully.
 
EC2 IP: ${EC2_IP}
 
✔ Terraform Provisioning
✔ Ansible Configuration
✔ Application Deployed
"""
        }
 
        failure {
            mail to: "${EMAIL_TO}",
                 subject: "❌ Jenkins Pipeline FAILED – DevOps Master Project",
                 body: """
Pipeline failed.
 
Check Jenkins console output immediately.
"""
        }
    }
}
