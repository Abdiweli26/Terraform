
1- Define a AMI
2- Define instance type
3- Define availability zone
4- Create a subnet 
5- For the route table i need a internet gateway 
6- create a sg, for inbound set type ssh, protocol tcp, port 22, source 0.0.0.0/0
for outbound I'll define the type as all traffic, destination type and destination as 0.0.0.0/0
7- create a ec2-ssm-role and attach it to the instance 
8- Define the the user data on the instance, set the commands, 