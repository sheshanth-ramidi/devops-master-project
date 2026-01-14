pipeline {
    agent any
 
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
 
        TF_DIR       = "terraform"
        ANSIBLE_DIR  = "ansible"
        INVENTORY    = "ansible/inventory/hosts"
 
        SSH_KEY      = "/var/lib/jenkins/.ssh/devops-key.pem"
        EMAIL_TO     = "r.sheshanth@gmail.com"
    }
 
    options {
        timestamps()
    }
 
    stages {
 
        /* -------------------- CHECKOUT -------------------- */
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sheshanth-ramidi/devops-master-project.git'
            }
        }
 
        /* -------------------- TERRAFORM INIT -------------------- */
        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        terraform init -reconfigure
                    '''
                }
            }
        }
 
        /* -------------------- TERRAFORM PLAN -------------------- */
        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        terraform plan
                    '''
                }
            }
        }
 
        /* -------------------- TERRAFORM APPLY -------------------- */
        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        terraform apply -auto-approve
                    '''
                }
            }
        }
 
        /* -------------------- FETCH EC2 PUBLIC IP -------------------- */
        stage('Fetch EC2 Public IP') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        env.EC2_IP = sh(
                            script: "terraform output -raw ec2_public_ip",
                            returnStdout: true
                        ).trim()
 
                        echo "EC2 Public IP: ${env.EC2_IP}"
                    }
                }
            }
        }
 
        /* -------------------- GENERATE ANSIBLE INVENTORY -------------------- */
        stage('Generate Ansible Inventory') {
            steps {
                script {
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
        }
 
        /* -------------------- PREPARE SSH -------------------- */
        stage('Prepare SSH') {
            steps {
                sh '''
                    chmod 600 /var/lib/jenkins/.ssh/devops-key.pem || true
                    ssh-keygen -R ${EC2_IP} || true
                '''
            }
        }
 
        /* -------------------- TEST ANSIBLE CONNECTIVITY -------------------- */
        stage('Test Ansible Connectivity') {
            steps {
                sh '''
                    ansible -i ansible/inventory/hosts web -m ping
                '''
            }
        }
 
        /* -------------------- RUN ANSIBLE PLAYBOOK -------------------- */
        stage('Run Ansible Playbook') {
            steps {
                sh '''
                    ansible-playbook -i ansible/inventory/hosts ansible/playbooks/web.yml
                '''
            }
        }
    }
 
    /* -------------------- EMAIL NOTIFICATIONS -------------------- */
    post {
        success {
            mail to: "${env.EMAIL_TO}",
                 subject: "✅ Jenkins Pipeline SUCCESS – DevOps Master Project",
                 body: """
Pipeline executed successfully.
 
EC2 IP: ${EC2_IP}
 
✔ Terraform Provisioning
✔ Ansible Configuration
✔ Application Deployment Completed
"""
        }
 
        failure {
            mail to: "${env.EMAIL_TO}",
                 subject: "❌ Jenkins Pipeline FAILED – DevOps Master Project",
                 body: """
Pipeline failed.
 
Please check Jenkins console output immediately.
"""
        }
    }
}
