provider "aws"{
    region = "ap-southeast-2"
    
    assume_role {
        role_arn = "arn:aws:iam::966294396589:role/GitHubAction-AssumeRoleWithAction"
        session_name = "tf-aws-joh887-cloud-resume-challenge"
        external_id = "joh887@github"
    }

}

terraform {
    required_version = ">= 1.0.0,< 2.0.0"
    
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }

    backend "s3"{
        bucket = "arn:aws:s3:::tf-aws-joh887-cloud-resume-challenge-state-bucket"
        key = "terraform.tfstate"
        region = "ap-southeast-2"
        encrypt = true
    }
}

