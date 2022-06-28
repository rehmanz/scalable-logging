# Scalable Logging

## Solution Overview

* [Pipenv](https://pipenv.pypa.io/en/latest/) is used to manage the application dependencies and unit tests
* API is containerized and stored in Amazon Elastic Container Registry (ECR)
* Application is deployed in AWS Elastic Container Service (ECS) and uses Postgres database as the backend
* Application logs are stored in Cloud Watch

## Build & Deployment Pipeline

The API is built and deployed using GitHub [Actions](https://github.com/rehmanz/aws-microservice/actions). The pipeline is divided into two stages:

#### Stage: build_app
* The prre-commit checks are performed and unit tests are run using docker compose
* Container is built and the image to a predefined AWS Elastic Container Registry is pushed

#### Stage: deploy_app
* Terraform plan and apply is run to update the infrastructure
* API, Postgres database and related infrastructure is deployed using Terraform. A secure S3 backend keeps track of the infrastructure state files.

## Security Considerations
* Secrets are stored securely as environment variables in local environment and as secrets in GitHub Actions
* Application is only accessible via a load balancer
* Direct access to database is not allowed
