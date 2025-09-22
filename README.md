# Deploying AWS Virtual Barista (Serverlesspresso)

## Prerequisites
- AWS CLI configured (`aws configure`)
- SAM CLI, Docker, Node.js, npm, Git installed

## Steps

1. **IAM Setup**  
   Create an IAM user and attach AdministratorAccess for deployment. Run `aws configure` with their credentials.

2. **Clone Repo**  
   ```
   git clone https://github.com/aws-samples/serverless-coffee.git
   cd serverless-coffee
   ```

3. **Deploy Core Stack**  
   ```
   cd 00-baseCore
   sam build
   sam deploy --guided
   ```
   Save CloudFormation outputs (UserPoolID, EventBus ARN, IoT endpoint).

4. **Deploy App Microservices**  
   ```
   cd ../01-appCore
   sam build
   sam deploy --guided
   ```

5. **Deploy EventPlayer (optional)**  
   ```
   cd ../extensibility/EventPlayer
   sam build
   sam deploy --guided
   aws stepfunctions start-execution \
     --state-machine-arn arn:aws:states:us-east-1:ACCOUNT:stateMachine:EventPlayer \
     --input '{}'
   ```

6. **Emit Test Event**  
   Place `events.json` in root and run:
   ```
   aws events put-events --entries file://events.json
   ```

7. **API Example**  
   Replace `<API_URL>` with your endpoint:
   ```
   curl -X POST "https://<API_URL>/basket/user-1/items" \
     -H "Content-Type: application/json" \
     -d '{"itemId":"espresso","qty":1}'
   curl -X POST "https://<API_URL>/basket/user-1/checkout"
   ```

8. **Lex Bot Lambda Handler**  
   Use `lex-order-handler.js` in your Lambda function for Lex bot fulfillment.

9. **Polly Voice Response**  
   ```
   aws polly synthesize-speech \
     --voice-id Matthew \
     --output-format mp3 \
     --text "Thanks — your espresso will be ready in about 2 minutes." \
     output.mp3
   ```

10. **Real-time Updates**  
   Use IoT endpoint for order status updates.

11. **Teardown**  
   ```
   aws cloudformation delete-stack --stack-name serverlesspresso
   aws cloudformation delete-stack --stack-name serverlesspresso-core
   ```