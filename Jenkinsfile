pipeline {
  agent any
 
  environment {
    AWS_DEFAULT_REGION = "ap-south-1"
    TF_DIR             = "terraform"
    ANSIBLE_DIR        = "ansible"
    INVENTORY          = "ansible/inventory/hosts"
    SSH_KEY            = "/var/lib/jenkins/.ssh/devops-key.pem"
 
    AWS_ACCOUNT_ID     = "741960641924"
 
    // EC2 flow (existing)
    ECR_REPO           = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/devops-master-app"
    IMAGE_TAG          = "latest"
 
    // Phase 8 (NEW)
    BACKEND_ECR_REPO   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/devops-master-backend"
    FRONTEND_ECR_REPO  = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/devops-master-frontend"
 
    EMAIL_TO           = "r.sheshanthr@gmail.com"
  }
 
  options {
    timestamps()
  }
 
  stages {
 
    /* ====================== PHASE 3 ====================== */
 
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
            sh """
              terraform init -reconfigure
              terraform apply -auto-approve
            """
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
 
    /* ====================== PHASE 4 ====================== */
 
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
 
    /* ====================== PHASE 5 ====================== */
 
    stage('Build Docker Image (EC2 App)') {
      steps {
        sh "docker build -t devops-master-app:${IMAGE_TAG} Docker/"
      }
    }
 
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
 
    stage('Tag & Push Image to ECR (EC2 App)') {
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
          ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${EC2_IP} '
            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} |
            docker login --username AWS --password-stdin ${ECR_REPO}
 
            docker pull ${ECR_REPO}:${IMAGE_TAG}
            docker stop app || true
            docker rm app || true
            docker run -d --name app -p 80:80 ${ECR_REPO}:${IMAGE_TAG}
          '
        """
      }
    }
 
    /* ====================== PHASE 6 ====================== */
 
    stage('Deploy to EKS') {
      steps {
        sh """
          aws eks update-kubeconfig \
            --region ${AWS_DEFAULT_REGION} \
            --name devops-eks-cluster
 
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
        """
      }
    }
 
    stage('Verify EKS Deployment') {
      steps {
        sh """
          kubectl rollout status deployment/devops-app
          kubectl get svc
        """
      }
    }
 
    /* ====================== PHASE 8 ====================== */
 
    stage('Phase 8 - Build & Push Backend Image') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-jenkins'
        ]]) {
          sh """
            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} |
            docker login --username AWS --password-stdin ${BACKEND_ECR_REPO}
 
            docker build -t devops-backend:latest app/backend
            docker tag devops-backend:latest ${BACKEND_ECR_REPO}:latest
            docker push ${BACKEND_ECR_REPO}:latest
          """
        }
      }
    }
 
    stage('Phase 8 - Build & Push Frontend Image') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-jenkins'
        ]]) {
          sh """
            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} |
            docker login --username AWS --password-stdin ${FRONTEND_ECR_REPO}
 
            docker build -t devops-frontend:latest app/frontend
            docker tag devops-frontend:latest ${FRONTEND_ECR_REPO}:latest
            docker push ${FRONTEND_ECR_REPO}:latest
          """
        }
      }
    }
 
    stage('Phase 8 - Deploy Frontend & Backend to EKS') {
      steps {
        sh """
          aws eks update-kubeconfig \
            --region ${AWS_DEFAULT_REGION} \
            --name devops-eks-cluster
 
          kubectl apply -f k8s/backend-deployment.yaml
          kubectl apply -f k8s/backend-service.yaml
          kubectl apply -f k8s/frontend-deployment.yaml
          kubectl apply -f k8s/service.yaml
        """
      }
    }
  }
 
  post {
    success {
      emailext(
        to: "${EMAIL_TO}",
        subject: "✅ Jenkins SUCCESS - DevOps Master Project",
        body: """
Pipeline completed successfully.
 
EC2 IP: ${EC2_IP}
 
Phases Completed:
✔ Terraform
✔ Ansible
✔ Docker Build
✔ ECR Push
✔ EC2 Deployment
✔ EKS Deployment
✔ Frontend & Backend on EKS
"""
      )
    }
 
    failure {
      emailext(
        to: "${EMAIL_TO}",
        subject: "❌ Jenkins FAILED - DevOps Master Project",
        body: "Pipeline failed. Check Jenkins logs."
      )
    }
  }
}
