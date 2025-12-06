data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/app.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "flash-msg-api"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.vault.name
    }
  }
}
