DevOps Technical Assignment


Introduction : 

    I am attending the DevOps project at Syvora. Which is based on simple deployment of CURD (copy,update,read,delete) by using python django code. In github repositories I wrote some sample code for deployment . In that main content is deployment.yaml , service.yaml , dockerfile 
Which can be played important role for making variations in deployment , control application initialization on a deployed container & for image build up . And now mention below all steps with full details are following.



Requirements Solutions : 

For moving forward step by step : 

Step 1)  ====To clone the git repo on ec2 ubuntu====

1--Launch a new EC2 instance.
Note - Configure the security group to allow SSH (port 22) and, if necessary, other ports for your application.

2–In first steps i am taking the github sample code for deployment this is the sample python django code. 

Link of git repository : https://github.com/Sakshione/Assignment-.git 
Here my repo are located which I am using .

3 – install git on server if not by defualt installed
 
**command--  sudo apt install git

4 – Configure Git:

Before you can clone a repository, you should configure your Git identity by setting your name and email address:

git config --global user.name "Your Name"
git config --global user.email "youremail@example.com"


5 – Clone the GitHub Repository:

To clone a GitHub repository, use the git clone command. 

**command--  git clone repository_url

6 –  Provide Authentication (if needed):

If the GitHub repository is private or requires authentication, you may need to provide your GitHub credentials. You can do this by either using an SSH key or by configuring Git to use a personal access token.

7– Navigate to the Cloned Repository:

After cloning, you can navigate to the cloned repository by using the cd command:

**command--  cd repo


Step 2 ====jenkins need to install on server ====

Note – before installation of jenkins need to install java (jdk)
With the help of this 
 **command  – sudo apt install openjdk-11-jdk


1– for installing jenkins we need to use following sub - steps

For installing jenkins before we need to give jenkins repository & key 
Command – wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add 

2 – once update the server & install command should run 
  Command – sudo apt update
                      sudo apt install jenkins

3– for start jenkins server 
  Command – sudo systemctl start jenkins

Note - setup jenkins Create a Jenkins Job:

Log in to the Jenkins web interface.
Click on "New Item" to create a new Jenkins job.
Choose a "Freestyle project" or a "Pipeline" job based on your requirements.
In the job configuration, you'll need to specify the details of your build. For a Pipeline job, you can use a Jenkinsfile to define your build steps.
For 
Step 3 =====for build an image install docker on server  =====

1– sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

2– for making ci/cd create one pipeline  in that pipeline mentioned :  cloning to github , build an image, push image to ECR ,deploying to kubernates I am create .

For this  I wrote script from git cloning to kubernates deployment is as followed mention,
 
stages{
        stage('Cloning to Git_Hub'){
            steps{
              git branch: 'prod', credentialsId: 'GIT', url: 'https://github.com/Sakshione/Assignment-.git'
            }
        }
   
        stage('Build an Image'){
            steps{
                script{
                    sh 'docker build -t xyzbackend .'
                 
                }
            }
        }
        
        stage('Pushing Image to ECR'){
            steps{
                
              script{
                    sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 692454607546.dkr.ecr.ap-south-1.amazonaws.com'
                    sh 'docker tag xyzbackend:latest 692454607546.dkr.ecr.ap-south-1.amazonaws.com/rezangbackend:latest'
                    sh 'docker push 692454607546.dkr.ecr.ap-south-1.amazonaws.com/xyzbackend:latest'
             }
          }
        }

        stage('Deploying to Kubernetes'){
            steps{
                  script{
                    // sh 'kubectl get pods -A'
                    // sh "kubectl apply -f deployment.yaml -n xyznamespace"
                      sh "kubectl delete pod \$(kubectl get pod -n xyznamespace | grep python-app | awk '{print \$1}') -n xyznamespace"

                    // sh 'kubectl apply --kubeconfig=/home/ubuntu/config -f deployment.yaml -n test'
                    // sh "kubectl apply -f service.yaml -n xyznamespace"

                 }
             }
        }
        
    }
}


Note - 1) for git cloning I am using this script step in jenkins 
stages{
        stage('Cloning to Git_Hub'){
            steps{
              git branch: 'prod', credentialsId: 'GIT', url: 'https://github.com/Sakshione/Assignment-.git'
            }
        }

2) for building image I am using this script 
stage('Build an Image'){
            steps{
                script{
                    sh 'docker build -t xyzbackend .'

3)for pushing the image I am using this script when I wrote this one that time I put the credential of ECR for logging & connecting with jenkins  & in that I tagged first docker image after that pushed the image in ECR successfully .

        stage('Pushing Image to ECR'){
            steps{
                
              script{
                    sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 692454607546.dkr.ecr.ap-south-1.amazonaws.com'
                    sh 'docker tag xyzbackend:latest 692454607546.dkr.ecr.ap-south-1.amazonaws.com/rezangbackend:latest'
                    sh 'docker push 692454607546.dkr.ecr.ap-south-1.amazonaws.com/xyzbackend:latest'
             }
          }
4) for deployment in kubernate I wrote below steps in that I did for deployment in kubernates I applied the deployment.yaml file & service.yaml file with the help of namespace which is created on server.

stage('Deploying to Kubernetes'){
            steps{
                  script{
               
                      sh "kubectl apply -f deployment.yaml -n xyznamespace"
                      sh "kubectl apply -f service.yaml -n xyznamespace"
                      }






Step 4====Install the kubernates ====

1–For installing the kubernates we can use kubectl  (once update the server by using “sudo apt upgrade”)
Command:   sudo apt install -y  kubectl

2– for insilizing the kubernates ( for worker node or master node)
Command : sudo kubectl init --pod-network-cidr=10.244.0.0/16

Note – when we are installed kubernate after manually in EKS services I created cluster in that cluster created one node group .

Step 5  ====Manage set up of server =====

*Bold points are bellowed for making server run support*

1)For accessing on browser I am  using classic load balancer / cluster ip .
2)For showing the cluster ip / external ip I am using below command : 
“kubectl get svc -n xyznamespace”

root@ip-172-31-10-14:/home/ubuntu# kubectl get svc -n prod
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                      PORT(S)        AGE
python-app-service   LoadBalancer   10.100.195.242   a917b6c9eda4i4cea951d9a6bada217f-01e0f6b2e4b4f2eb.elb.ap-south-1.amazonaws.com   80:327 73/TCP   44d

3)For checking the pods 
Command : “kubectl get pods -A”


4)For monitor purpose applications, infrastructure, network, and services i am using Cloud Watch .
By default python django is using this database db.sqlite3 but I am using DynamoDB & db.sqlite3 for performing the CURD operation. 




