import boto3
import os
import time
import uuid
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}") 
    path = event.get('rawPath', '')
    
    def response(code, body):
        return {
            "statusCode": code,
            "body": json.dumps(body),
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*", # Ensure CORS works from Lambda side too
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            }
        }

    # Handle CORS preflight just in case
    if event.get('requestContext', {}).get('http', {}).get('method') == 'OPTIONS':
        return response(200, {})

    try:
        # --- WRITE PATH (Create Secret) ---
        if path == '/create':
            if not event.get('body'):
                return response(400, {"error": "Missing body"})
            
            body = json.loads(event['body'])
            if 'text' not in body:
                 return response(400, {"error": "Missing 'text' field"})

            secret_id = str(uuid.uuid4().hex[:8])
            
            # Calculate expiry (current time + 24 hours)
            expiry = int(time.time() + 86400) 
            
            table.put_item(Item={
                'secret_id': secret_id,
                'secret_text': body['text'],
                'expiry_timestamp': expiry
            })
            
            return response(200, {"id": secret_id})

        # --- READ PATH (The Self-Destruct) ---
        elif path.startswith('/read/'):
            secret_id = path.split('/')[-1]
            
            # 1. Get the secret
            resp = table.get_item(Key={'secret_id': secret_id})
            
            if 'Item' not in resp:
                return response(404, {"error": "Message not found or already destroyed."})
                
            # 2. DESTROY IT IMMEDIATELY
            table.delete_item(Key={'secret_id': secret_id})
            
            # 3. Return the content
            return response(200, {"message": resp['Item']['secret_text']})
        
        else:
            return response(404, {"error": "Not Found"})

    except Exception as e:
        print(f"Error: {str(e)}")
        return response(500, {"error": str(e)})
