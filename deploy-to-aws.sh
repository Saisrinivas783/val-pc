#!/bin/bash

# Deployment script for Valentine's Day project to AWS S3

echo "===================================="
echo "Valentine's Day Project AWS Deployment"
echo "===================================="
echo ""

# Set your bucket name (must be globally unique)
BUCKET_NAME="valentine-pc-project-$RANDOM"
echo "Bucket name: $BUCKET_NAME"
echo ""

# Create S3 bucket
echo "Creating S3 bucket..."
aws s3 mb s3://$BUCKET_NAME --region us-east-1

if [ $? -ne 0 ]; then
    echo "Failed to create bucket. It might already exist or you need to configure AWS CLI."
    exit 1
fi

# Upload files to S3
echo ""
echo "Uploading files to S3..."
aws s3 cp valentine.html s3://$BUCKET_NAME/valentine.html --content-type "text/html"
aws s3 cp style.css s3://$BUCKET_NAME/style.css --content-type "text/css"
aws s3 cp script.js s3://$BUCKET_NAME/script.js --content-type "application/javascript"

# Make files publicly readable
echo ""
echo "Making files public..."
aws s3api put-object-acl --bucket $BUCKET_NAME --key valentine.html --acl public-read
aws s3api put-object-acl --bucket $BUCKET_NAME --key style.css --acl public-read
aws s3api put-object-acl --bucket $BUCKET_NAME --key script.js --acl public-read

# Enable static website hosting
echo ""
echo "Enabling static website hosting..."
aws s3 website s3://$BUCKET_NAME/ --index-document valentine.html

# Update bucket policy for public access
echo ""
echo "Setting bucket policy for public access..."
cat > policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://policy.json
rm policy.json

echo ""
echo "===================================="
echo "Deployment Complete!"
echo "===================================="
echo ""
echo "Your website is now live at:"
echo "http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
echo ""
echo "Save this URL!"
echo "===================================="
