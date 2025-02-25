import os
import json
import boto3
from PIL import Image
import io

s3_client = boto3.client('s3')
THUMBNAIL_SIZE = int(os.environ.get('THUMBNAIL_SIZE', 128))

def lambda_handler(event, context):
    # Get the S3 bucket and key from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    try:
        # Download the image from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        image_content = response['Body'].read()
        
        # Process the image
        with Image.open(io.BytesIO(image_content)) as img:
            # Create thumbnail
            img.thumbnail((THUMBNAIL_SIZE, THUMBNAIL_SIZE), Image.LANCZOS)
            
            # Save the thumbnail to a bytes buffer
            buffer = io.BytesIO()
            img.save(buffer, format=img.format)
            buffer.seek(0)
            
            # Upload the thumbnail to the output bucket
            output_bucket = os.environ.get('OUTPUT_BUCKET')
            output_key = f"thumbnail_{key}"
            
            s3_client.put_object(
                Bucket=output_bucket,
                Key=output_key,
                Body=buffer,
                ContentType=f'image/{img.format.lower()}'
            )
            
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Thumbnail created successfully',
                'input_image': f"{bucket}/{key}",
                'output_image': f"{output_bucket}/{output_key}"
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error creating thumbnail',
                'error': str(e)
            })
        }
