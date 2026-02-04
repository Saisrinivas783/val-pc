# AWS S3 Deployment Guide for Valentine's Day Project 💝

## Prerequisites

Before deploying, make sure you have:

1. **AWS Account** - Sign up at https://aws.amazon.com if you don't have one
2. **AWS CLI Installed** - Download from https://aws.amazon.com/cli/
3. **AWS Credentials Configured** - Run `aws configure` and enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region: `us-east-1`
   - Default output format: `json`

## Quick Deployment Steps

### Option 1: Automatic Deployment (Recommended)

**For Windows:**
```bash
deploy-to-aws.bat
```

**For Mac/Linux:**
```bash
chmod +x deploy-to-aws.sh
./deploy-to-aws.sh
```

The script will:
- Create an S3 bucket with "pc" in the name (e.g., `valentine-pc-project-12345`)
- Upload all project files
- Configure static website hosting
- Make the files publicly accessible
- Display your website URL

### Option 2: Manual Deployment

1. **Create S3 Bucket**
   ```bash
   aws s3 mb s3://valentine-pc-YOUR-NAME --region us-east-1
   ```
   *Replace YOUR-NAME with something unique*

2. **Upload Files**
   ```bash
   aws s3 cp valentine.html s3://valentine-pc-YOUR-NAME/
   aws s3 cp style.css s3://valentine-pc-YOUR-NAME/
   aws s3 cp script.js s3://valentine-pc-YOUR-NAME/
   ```

3. **Enable Static Website Hosting**
   ```bash
   aws s3 website s3://valentine-pc-YOUR-NAME/ --index-document valentine.html
   ```

4. **Make Bucket Public** (via AWS Console)
   - Go to S3 Console: https://s3.console.aws.amazon.com/
   - Select your bucket
   - Go to "Permissions" tab
   - Uncheck "Block all public access"
   - Add bucket policy (see below)

5. **Bucket Policy**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::valentine-pc-YOUR-NAME/*"
       }
     ]
   }
   ```

## Your Website URL

After deployment, your website will be accessible at:
```
http://valentine-pc-YOUR-BUCKET-NAME.s3-website-us-east-1.amazonaws.com
```

## Updating Your Website

To update files after making changes:
```bash
aws s3 sync . s3://valentine-pc-YOUR-NAME/ --exclude "*.md" --exclude "*.bat" --exclude "*.sh" --exclude ".git/*"
```

## Troubleshooting

### AWS CLI Not Found
- Install AWS CLI from: https://aws.amazon.com/cli/
- Restart your terminal after installation

### Bucket Name Already Exists
- S3 bucket names must be globally unique
- Try a different name: `valentine-pc-myname-2024`

### 403 Forbidden Error
- Check bucket policy is applied correctly
- Ensure "Block all public access" is OFF
- Verify files have public-read ACL

### Files Not Loading
- Check content-type is set correctly
- Clear browser cache (Ctrl+F5)
- Wait a few minutes for changes to propagate

## Cost Information

S3 static website hosting is very affordable:
- **Storage**: ~$0.023 per GB/month (your site is <1MB)
- **Requests**: ~$0.0004 per 1,000 GET requests
- **Free Tier**: 5GB storage + 20,000 GET requests/month for first 12 months

**Estimated cost for this project**: Less than $0.01/month! 💰

## Next Steps (Optional)

### Add Custom Domain with "PC"
1. Buy a domain like `valentine-pc.com` from Route 53
2. Configure Route 53 to point to your S3 bucket
3. Add CloudFront for HTTPS support

### Add HTTPS
1. Use AWS CloudFront distribution
2. Request free SSL certificate from AWS Certificate Manager
3. Configure CloudFront to use your S3 bucket as origin

---

## Need Help?

- AWS S3 Documentation: https://docs.aws.amazon.com/s3/
- AWS Support: https://aws.amazon.com/support/
- AWS Free Tier: https://aws.amazon.com/free/

Happy Valentine's Day! 💕
