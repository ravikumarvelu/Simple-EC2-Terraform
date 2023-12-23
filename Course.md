Case Study – Continuous Integration  
 
Goal 
Create a build pipeline job  
 
Details    
1)	Install build pipeline plugin 
2)	Configure email with Jenkins 
3)	Create a slave and call it QA environment 
4)	Create a pipeline job and trigger it when developer commits the code in GIT 
5)	Build the code using Maven/Ant and send the notification to developer in case of build fail 6) Unit test the code using Junit  
7)	Do static code analysis using SonarQube, create quality gate to pass to next environment 
8)	Create the package and store in Artifactory/Nexus 
9)	Create another job to deploy the code from Artifactory/Nexus to slave QA and host it 
10)	View the status both upstream and downstream job in the dashboard of Jenkins 
11)	Fail the build and check if email is triggered 
12)	Fail the quality gate and check if packaging is failed
