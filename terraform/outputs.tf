output "api_url" {
  description = "The public URL of the FlashMsg API"
  value       = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

output "website_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}
