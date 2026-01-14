pipeline {
    agent any
 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
 
        TF_DIR      = 'terraform'
        ANSIBLE_DIR = 'ansible'
        INVENTORY   = 'ansible/inventory/hosts'
 
        // 🔑 ONLY CHANGE HERE
        SSH_KEY     = '/var/lib/jenkins/.ssh/devops-key.pem'
 
        EMAIL_TO    = 'r.sheshanthr@gmail.com'
    }
 
    options {
        timestamps()
    }
 
    stages {
 
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
 
        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init -reconfigure'
                }
            }
        }
 
        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }
 
        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
 
        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
 
        stage('Fetch EC2 Public IP') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        EC2_IP = sh(
                            script: "terraform output -raw ec2_public_ip",
                            returnStdout: true
                        ).trim()
 
                        echo "EC2 Public IP: ${EC2_IP}"
                    }
                }
            }
        }
 
        stage('Generate Ansible Inventory') {
            steps {
                sh """
                mkdir -p ansible/inventory
 
                cat <<EOF > ${INVENTORY}
[web]
web1 ansible_host=${EC2_IP}
 
[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=${SSH_KEY}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
                """
            }
        }
 
        stage('Prepare SSH') {
            steps {
                sh """
                chmod 600 ${SSH_KEY}
                ssh-keygen -R ${EC2_IP} || true
                """
            }
        }
 
        stage('Test Ansible Connectivity') {
            steps {
                sh """
                ansible -i ${INVENTORY} web -m ping
                """
            }
        }
 
        stage('Run Ansible Playbook') {
            steps {
                sh """
                ansible-playbook -i ${INVENTORY} ansible/site.yml
                """
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
