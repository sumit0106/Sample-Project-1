pipeline{
    agent any
    parameters {
        choice(name: 'Action', choices: ['Apply', 'Destroy'], description: 'Select the action to to perform')
    }
    tools {
        terraform 'Terraform' 
    }
    stages{
        stage("Git Clone"){
            steps{
                sh 'git clone https://github.com/sumit0106/Sample-Project-1.git'
            }
        }
        stage("Terraform Init"){
            steps{
                dir ('/var/lib/jenkins/workspace/Project/Sample-Project-1'){
                sh 'terraform init'
            }
            }
        }
        stage("Terraform Plan"){
            steps{
                dir ('/var/lib/jenkins/workspace/Project/Sample-Project-1'){
                sh 'terraform plan'
            }
            }
        }
        stage("Apply/Destroy"){
            steps{
                script {
                    def ActionDone = params.Action
                    if(ActionDone == 'Apply'){
                        dir ('/var/lib/jenkins/workspace/Project/Sample-Project-1'){
                        sh 'terraform apply --auto-approve'
                    }
                    }
                    else if (ActionDone == 'Destroy'){
                        dir ('/var/lib/jenkins/workspace/Project/Sample-Project-1'){
                        sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }
    }
}}