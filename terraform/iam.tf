# 1. The Role: Who is acting? (The Lambda Function)
resource "aws_iam_role" "lambda_exec" {
  name = "flash_msg_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. The Policy: What can they do? (Least Privilege)
resource "aws_iam_policy" "lambda_policy" {
  name        = "flash_msg_lambda_policy"
  description = "Allow Lambda to write logs and access only the specific DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Logging (Standard for debugging)
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      # Database Access (Granular!)
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.vault.arn
      }
    ]
  })
}

# 3. Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
