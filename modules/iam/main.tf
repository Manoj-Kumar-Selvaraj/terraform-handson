resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "LambdaAndSNSFullAccess"
  description = "Policy to grant Lambda and SNS permissions along with existing EC2 and S3 access."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_lambda_sns_policy" {
  user       = "GitPod"  # Replace with actual IAM user name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

resource "aws_iam_policy" "S3ReadOnly" {
  name        = "S3ReadOnlyPolicy"
  description = "Policy to grant read-only access for S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:ListAllMyBuckets"  # This should be important for any list
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_read_only_policy" {
  user       = "S3_Read_Only_Manoj"  # Replace with actual IAM user name
  policy_arn = aws_iam_policy.S3ReadOnly.arn
}

# Create IAM User EC2ReadOnly
resource "aws_iam_user" "EC2ReadOnly" {
  name = "EC2ReadOnly"
}

# Create IAM Group ec2 if it doesn't exist
resource "aws_iam_group" "ec2" { 
  name = "ec2" 
}

# Create the EC2 Read-Only policy

# Check this doc https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-configure-IAM-role.html

resource "aws_iam_policy" "EC2ReadOnlyPolicy" {
  name        = "EC2ReadOnlyPolicy"
  description = "Read-only access to EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2-instance-connect:SendSSHPublicKey",    # This is important
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkInterfaces",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:Connect"
        ]
        Resource = "*"
      },{
        Effect = "Allow"
        Action = "elasticloadbalancing:Describe*"
        Resource = "*"
      },
              {
            Effect = "Allow",
            Action = [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow",
            Action = "autoscaling:Describe*",
            Resource = "*"
        }
    ]
  })
}

# Attach the EC2 Read-Only policy to the ec2 group
resource "aws_iam_group_policy_attachment" "attach_ec2_readonly_policy_to_group" {
  group      = aws_iam_group.ec2.name
  policy_arn = aws_iam_policy.EC2ReadOnlyPolicy.arn
}

# Attach the user EC2ReadOnly to the ec2 group
resource "aws_iam_user_group_membership" "EC2ReadOnly_to_group" {
  user  = aws_iam_user.EC2ReadOnly.name
  groups  = [aws_iam_group.ec2.name]
}

# Create login profile (console access) for EC2ReadOnly user and set password
resource "aws_iam_user_login_profile" "EC2ReadOnly_login" {
  user    = aws_iam_user.EC2ReadOnly.name
  # password = "TheNewPasswordNov@2" # This is managed automatically by AWS and its not allowed in terraform.
  password_reset_required = true  # Set to true if you want the user to change the password on first login
}

/*

When you create an IAM user in AWS, 
the system does not automatically send an email to the user with login details unless you explicitly configure it. 
AWS will not send any login credentials by default.
https://<account-id>.signin.aws.amazon.com/console.

*/

resource "aws_iam_policy" "EC2LaunchandConnectPolicy" {
  name        = "EC2LaunchandConnectPolicy"
  description = "EC2LaunchandConnectPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:LaunchInstances",
          "ec2:CreateSecurityGroup",            
          "ec2:DescribeKeyPairs",
          "ec2:ModifyInstanceAttribute",
          "ec2:DeleteSecurityGroup", 
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:CreateTags",                  
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_user" "EC2LaunchandConnect" {
  name = "EC2LaunchandConnect"
}

resource "aws_iam_user_login_profile" "EC2LaunchandConnect_login" {
  user    = aws_iam_user.EC2LaunchandConnect.name
  password_reset_required = true  # Set to true if you want the user to change the password on first login
}

resource "aws_iam_user_group_membership" "EC2LaunchandConnect_to_group" {
  user  = aws_iam_user.EC2LaunchandConnect.name
  groups  = [aws_iam_group.ec2.name]
}

resource "aws_iam_user_policy_attachment" "EC2LaunchandConnect_attach" {
  user = aws_iam_user.EC2LaunchandConnect.name
  policy_arn = aws_iam_policy.EC2LaunchandConnectPolicy.arn
}

resource "aws_iam_policy" "iam_list_users_policy" {
  name        = "iam_list_users_policy"
  description = "iam_list_users_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "iam:List*",
          "iam:Get*",             
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "iam_read_only_user" {
  name = "iam_read_only_user"
}

resource "aws_iam_user_login_profile" "iam_read_only_user_login" {
  user = aws_iam_user.iam_read_only_user.name
  password_reset_required = true
}

resource "aws_iam_group" "iam_group" {
  name = "iam"
}

resource "aws_iam_user_group_membership" "attach_iam_read_only_user_login" {
  user = aws_iam_user.iam_read_only_user.name
  groups = [aws_iam_group.iam_group.name]
}

resource "aws_iam_group_policy_attachment" "attach_iam_list_users_policy" {
  group = aws_iam_group.iam_group.name
  policy_arn = aws_iam_policy.iam_list_users_policy.arn
}

/*
Lets start with conditions in IAM
https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition.html
https://docs.aws.amazon.com/pdfs/service-authorization/latest/reference/service-authorization.pdf#reference_policies_actions-resources-contextkeys
"Condition" : { "{condition-operator}" : { "{condition-key}" : "{condition-value}" }}
ex : "Condition" : { "StringEquals" : { "aws:username" : "johndoe" }}
*/

