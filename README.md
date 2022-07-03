Terraform example of providing AWS environment to host a production web application for internal teams with a database backend.

## Context
Deploy an AWS environment to host a production web application for internal teams with a database backend. The application will run on EC2 instance on port 443.

## Assumptions
- To simplify the example, web application server and database will each use 1 instance with small instance type as default.
- The web application will be baked and setup into AMI image that can be used when created an EC2 instance.
- The web application maintainers might need to SSH into the web application server from time to time to troubleshooting database that will be hosted in a private subnet.

## Inputs
See the file `variables.tf` for more details, default value and example value.

## Outputs
See the file `outputs.tf` for more details.
