# AWS Image Builder Pipeline

This repository contains Terraform configurations for setting up an automated AWS Image Builder pipeline to create customized AMIs.

## Overview

The infrastructure creates:

- A dedicated VPC with public subnet for Image Builder
- S3 bucket for Image Builder logs with appropriate security controls
- Example Windows Server 2022 image recipe with latest updates
- Automated pipeline that runs monthly to create updated images
- IAM roles and policies for Image Builder operations
- Multi-region AMI distribution capability

## Prerequisites

- Terraform >= 0.13
- AWS credentials configured
- AWS CLI
