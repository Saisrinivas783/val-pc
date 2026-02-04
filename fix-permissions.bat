@echo off
REM Fix permissions for valentine-pc-project-4032

set BUCKET_NAME=valentine-pc-project-4032

echo Fixing Block Public Access settings...
echo.

REM Disable Block Public Access for this bucket
aws s3api put-public-access-block --bucket %BUCKET_NAME% --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo.
echo Making files public...
aws s3api put-object-acl --bucket %BUCKET_NAME% --key valentine.html --acl public-read
aws s3api put-object-acl --bucket %BUCKET_NAME% --key style.css --acl public-read
aws s3api put-object-acl --bucket %BUCKET_NAME% --key script.js --acl public-read

echo.
echo Setting bucket policy...
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
echo Permissions Fixed!
echo ====================================
echo.
echo Your website is now live at:
echo http://%BUCKET_NAME%.s3-website-us-east-1.amazonaws.com
echo.
echo ====================================
pause
