# Scalable Logging

## Solution Overview

* [Pipenv](https://pipenv.pypa.io/en/latest/) is used to manage the application dependencies and unit tests
* API is containerized and stored in Amazon Elastic Container Registry (ECR)
* [Application](http://ecs-alb-461326369.us-west-2.elb.amazonaws.com/) is deployed in AWS Elastic Container Service (ECS) and uses Postgres database as the backend
* Application logs are stored in Cloud Watch


## Setup

### IAM Roles & Groups
A `github` machine account was created and assigned to the `ci` group with the following permissions. This account was used for automated deployment. This user only has AWS API access and no console access. Access can be more granular.

```commandline
AmazonEC2ContainerRegistryFullAccess
CloudWatchLogsFullAccess
IAMFullAccess
AmazonEC2FullAccess
ElasticLoadBalancingFullAccess
AmazonS3FullAccess
AmazonRDSFullAccess
AmazonEC2FullAccess
AmazonECSTaskExecutionRolePolicy
```

### Infrastructure Dependencies

* An S3 bucket `terraform-s0715c` was created for the terraform backend.
* The `scalable-logging` repository was manually set up into Amazon ECR.


## Build & Deployment Pipeline

GitHub [Actions](https://github.com/rehmanz/aws-microservice/actions) was used to build, test and deploy the application. The pipeline is divided into two stages:

#### Build

* Pre-commit hooks were used for linting, formatting and validating application and infrastructure code
* Basic logging and exception handling was added to app.py for debugging
* GitHub Actions was used to build the container and setup docker compose environment for unit testing. Subsequently, pytest was used to check application endpoints locally before pushing the code to a predefined AWS Elastic Container Registry
* Enhancements
  * Git tagging needs to be incorporated for proper versioning


#### Deploy
* Terraform was with an S3 bucket as the backend
* Sensitive secrets were fetched as environment variables from GitHub secrets
* Enhancements
  * Enable S3 bucket versioning
  * Container should use role based access for Postgres
  * Monitoring
    * PgAnalyze for monitoring Postgres DB
    * Data Dog for logs & metrics
    * Integrate Locust for scale-out and scale-in testing


## Terraform Infrastructure

![Terraform Infrastructure](.slogging_diagram)

VPC contains public and private subnets in two availability zones. Incoming requests are routed through the application load balancer to the EC2 instance (i.e. ecs-target-group) and then redirected to the container/task. Outgoing response from task/container, is routed through the EC2 instance and then from the NAT Gateway to the internet.

Cloudwatch was configured to send container and database maintenance logs to appropriate log groups.

Postgres database is only accessible via private subnets.



## Security Considerations
* Secrets are stored securely as environment variables in local environment and as secrets in GitHub Actions
* Application is only accessible via a load balancer
* Direct access to database is not allowed
