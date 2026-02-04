@echo off
REM Deployment script for Valentine's Day project to AWS S3

echo ====================================
echo Valentine's Day Project AWS Deployment
echo ====================================
echo.

REM Set your bucket name (must be globally unique)
set BUCKET_NAME=valentine-pc-project-%RANDOM%
echo Bucket name: %BUCKET_NAME%
echo.

REM Create S3 bucket
echo Creating S3 bucket...
aws s3 mb s3://%BUCKET_NAME% --region us-east-1
if %errorlevel% neq 0 (
    echo Failed to create bucket. It might already exist or you need to configure AWS CLI.
    pause
    exit /b 1
)

REM Upload files to S3
echo.
echo Uploading files to S3...
aws s3 cp valentine.html s3://%BUCKET_NAME%/valentine.html --content-type "text/html"
aws s3 cp style.css s3://%BUCKET_NAME%/style.css --content-type "text/css"
aws s3 cp script.js s3://%BUCKET_NAME%/script.js --content-type "application/javascript"

REM Make files publicly readable
echo.
echo Making files public...
aws s3api put-object-acl --bucket %BUCKET_NAME% --key valentine.html --acl public-read
aws s3api put-object-acl --bucket %BUCKET_NAME% --key style.css --acl public-read
aws s3api put-object-acl --bucket %BUCKET_NAME% --key script.js --acl public-read

REM Enable static website hosting
echo.
echo Enabling static website hosting...
aws s3 website s3://%BUCKET_NAME%/ --index-document valentine.html

REM Update bucket policy for public access
echo.
echo Setting bucket policy for public access...
echo { > policy.json
echo   "Version": "2012-10-17", >> policy.json
echo   "Statement": [ >> policy.json
echo     { >> policy.json
echo       "Sid": "PublicReadGetObject", >> policy.json
echo       "Effect": "Allow", >> policy.json
echo       "Principal": "*", >> policy.json
echo       "Action": "s3:GetObject", >> policy.json
echo       "Resource": "arn:aws:s3:::%BUCKET_NAME%/*" >> policy.json
echo     } >> policy.json
echo   ] >> policy.json
echo } >> policy.json

aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy file://policy.json
del policy.json

echo.
echo ====================================
echo Deployment Complete!
echo ====================================
echo.
echo Your website is now live at:
echo http://%BUCKET_NAME%.s3-website-us-east-1.amazonaws.com
echo.
echo Save this URL!
echo ====================================
pause
