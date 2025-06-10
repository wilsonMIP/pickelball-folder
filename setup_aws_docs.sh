#!/bin/bash

# Create docs/aws directory if it doesn't exist
mkdir -p docs/aws

# Add AWS service docs as submodules
git submodule add -b main https://github.com/awsdocs/amazon-s3-userguide.git docs/aws/s3
git submodule add -b main https://github.com/awsdocs/amazon-dynamodb-developer-guide.git docs/aws/dynamodb
git submodule add -b main https://github.com/awsdocs/aws-lambda-developer-guide.git docs/aws/lambda
git submodule add -b main https://github.com/awsdocs/aws-secrets-manager-docs.git docs/aws/secrets-manager
git submodule add -b main https://github.com/aws-amplify/docs.git docs/aws/amplify
git submodule add -b main https://github.com/awsdocs/aws-doc-sdk-examples.git docs/aws/sdk-examples

# Create GitHub Actions workflow directory
mkdir -p .github/workflows

# Create the workflow file
cat > .github/workflows/update-aws-docs.yml << 'YAML'
name: "Bump AWS docs submodules"
on:
  schedule:
    - cron: "0 4 * * *"      # every day at 04:00 UTC
  workflow_dispatch:
permissions:
  contents: write
  packages: write
jobs:
  bump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      - run: |
          git submodule update --remote --merge
          if ! git diff --quiet; then
            git config user.name  "aws-docs-bot"
            git config user.email "aws-docs-bot@users.noreply.github.com"
            git commit -am "chore: daily AWS docs refresh"
            git push
          fi
YAML

# Commit and push changes
git add .
git commit -m "chore: add AWS docs submodules and daily refresh workflow"
git push 