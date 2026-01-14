pipeline {
    agent any
 
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        INVENTORY_FILE = "ansible/inventory/hosts"
    }
 
    stages {
 
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
 
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${TF_DIR}") {
                        sh 'terraform init'
                    }
                }
            }
        }
 
        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${TF_DIR}") {
                        sh 'terraform plan'
                    }
                }
            }
        }
 
        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${TF_DIR}") {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
 
        stage('Fetch EC2 Public IP') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${TF_DIR}") {
                        script {
                            EC2_IP = sh(
                                script: "terraform output -raw web_public_ip",
                                returnStdout: true
                            ).trim()
                            echo "EC2 Public IP: ${EC2_IP}"
                        }
                    }
                }
            }
        }
 
        stage('Generate Ansible Inventory') {
            steps {
                script {
                    sh """
                    mkdir -p ansible/inventory
                    cat <<EOF > ${INVENTORY_FILE}
[web]
web1 ansible_host=${EC2_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${WORKSPACE}/ansible/Ansible_key.pem
EOF
                    """
                }
            }
        }
 
        stage('Test Ansible Connectivity') {
            steps {
                sh """
                chmod 600 ansible/Ansible_key.pem
                ansible -i ${INVENTORY_FILE} web -m ping
                """
            }
        }
 
        stage('Run Ansible Playbook') {
            steps {
                sh """
                ansible-playbook -i ${INVENTORY_FILE} ansible/playbooks/web.yml
                """
            }
        }
    }
 
    post {
        success {
            mail to: 'yourmail@gmail.com',
                 subject: "SUCCESS: DevOps Master Project",
                 body: """Pipeline SUCCESS ✅
 
EC2 Public IP: ${EC2_IP}
 
Terraform + Ansible executed successfully.
"""
        }
 
        failure {
            mail to: 'yourmail@gmail.com',
                 subject: "FAILED: DevOps Master Project",
                 body: "Pipeline FAILED ❌. Check Jenkins logs."
        }
    }
}
