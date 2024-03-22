# configure aws account
Write-Output "AWS Access Key ID: test"
Write-Output "AWS Secret Access Key: test"
Write-Output "Default region name: us-east-1"
Write-Output "Default output format: json"
aws configure --profile localstack

# create localstack docker container
docker-compose up -d

# create secrets manager secrets
try {
    aws --endpoint-url=http://localhost:4566 `
        secretsmanager describe-secret `
        --secret-id "MySecret" `
        --no-cli-pager `
        --profile localstack | Out-Null

    aws --endpoint-url=http://localhost:4566 `
        secretsmanager update-secret `
        --secret-id "MySecret" `
        --secret-string '{"username":"myusername","password":"mypassword"}' `
        --no-cli-pager `
        --profile localstack
} catch {
    aws --endpoint-url=http://localhost:4566 `
        secretsmanager create-secret `
        --name "MySecret" `
        --description "My credentials" `
        --secret-string '{"username":"myusername","password":"mypassword"}' `
        --no-cli-pager `
        --profile localstack

}

# create s3 bucket
aws --endpoint-url=http://localhost:4566 `
    s3 mb s3://my-localstack-bucket `
  --no-cli-pager `
  --profile localstack

# finish
Read-Host "Press Enter to continue..."
