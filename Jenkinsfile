pipeline {
    agent any
 
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        TF_DIR      = "terraform"
        ANSIBLE_DIR = "ansible"
        INVENTORY   = "ansible/inventory/hosts"
        SSH_KEY     = "/var/lib/jenkins/.ssh/devops-key.pem"
 
        AWS_ACCOUNT_ID = "741960641924"
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/devops-master-app"
        IMAGE_TAG = "latest"
 
        EMAIL_TO = "r.sheshanthr@gmail.com"
    }
 
    options {
        timestamps()
    }
 
    stages {
 
        /* ================= PHASE-3 ================= */

        stage('Force Clean Workspace') {
            steps {
                sh '''
                  sudo rm -rf .git
                  git clean -fdx
                  '''
            }
         }
 
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sheshanth-ramidi/devops-master-project.git'
            }
        }
 
        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir("${TF_DIR}") {
                        sh '''
                        terraform init -reconfigure
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
                echo "EC2 IP: ${EC2_IP}"
            }
        }
 
        stage('Generate Ansible Inventory') {
            steps {
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
 
        stage('Run Ansible (Install Docker)') {
            steps {
                sh "ansible-playbook -i ${INVENTORY} ansible/playbooks/web.yml"
            }
        }
 
        /* ================= PHASE-4 ================= */
 
        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t devops-master-app:${IMAGE_TAG} Docker/
                """
            }
        }
 
        /* ================= PHASE-5 ================= */
 
        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} |
                    docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }
 
        stage('Tag & Push Image to ECR') {
            steps {
                sh """
                docker tag devops-master-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }
 
        stage('Deploy Container from ECR to EC2') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${EC2_IP} << EOF
                  aws ecr get-login-password --region ${AWS_DEFAULT_REGION} |
                  docker login --username AWS --password-stdin ${ECR_REPO}
                  docker stop app || true
                  docker rm app || true
                  docker pull ${ECR_REPO}:${IMAGE_TAG}
                  docker run -d --name app -p 80:80 ${ECR_REPO}:${IMAGE_TAG}
                EOF
                """
            }
        }
    }
 
    post {
        success {
            emailext(
                to: "${EMAIL_TO}",
                subject: "✅ Jenkins SUCCESS – DevOps Master Project",
                body: """
Pipeline completed successfully.
 
EC2 IP: ${EC2_IP}
 
Phases:
✔ Terraform
✔ Ansible
✔ Docker Build
✔ ECR Push
✔ EC2 Deployment
"""
            )
        }
 
        failure {
            emailext(
                to: "${EMAIL_TO}",
                subject: "❌ Jenkins FAILED – DevOps Master Project",
                body: "Pipeline failed. Check Jenkins logs."
            )
        }
    }
}
