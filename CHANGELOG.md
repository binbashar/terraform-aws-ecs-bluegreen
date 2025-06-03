# Changelog

All notable changes to this project will be documented in this file.

## [1.1.2](https://github.com/binbashar/terraform-aws-ecs-bluegreen/compare/v1.1.1...v1.1.2) (2025-06-03)


### Bug Fixes

* Update ALB and ECS configurations for improved networking and security settings ([aa25e07](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/aa25e072915439590a0fbb9ad25693383e249c7a))

## [1.1.1](https://github.com/binbashar/terraform-aws-ecs-bluegreen/compare/v1.1.0...v1.1.1) (2025-06-03)


### Bug Fixes

* Update resource reference in IAM policy and remove unused security groups output ([78a2139](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/78a21392d7783aefe6d06b5e042d8c5b06d23493))

## [1.1.0](https://github.com/binbashar/terraform-aws-ecs-bluegreen/compare/v1.0.0...v1.1.0) (2025-06-03)


### Features

* Test PR title ([c60ced7](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/c60ced7bc80e0b7432869b83690ad548fe5f794d))


### Bug Fixes

* Correct ARN reference in CloudWatch event target and rename services module to ecs_services ([0d98894](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/0d988945a31c0f26cd5aa86e75dfde636c2befc3))

## 1.0.0 (2025-05-21)


### Features

* Enhance Terraform module for AWS ECS Blue/Green deployment by adding support for health checks and auto-scaling configurations. ([4899745](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/489974502e77a0970f23c7109aea4413e572ec05))
* Initial commit of Terraform module for AWS ECS Blue/Green deployment, including ALB configuration, ECS services, deployment settings, and CI/CD integration with CodePipeline and CodeDeploy. ([2fdf05f](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/2fdf05f2449c014bda5447926d7a8c0826dff7e3))
* update default Git service configuration in variables.tf ([f330b99](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/f330b991d15008a0fe7c24dccda960eefd181877))
* update Git service configuration and enhance service scheduling variables ([7d2d9d6](https://github.com/binbashar/terraform-aws-ecs-bluegreen/commit/7d2d9d6dcf95da97e3c0b1ef38e9d7ca6418cc7a))
