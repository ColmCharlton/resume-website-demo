
const AWSXRay = require('aws-xray-sdk');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

const ses = new AWS.SES();
const cloudwatch = new AWS.CloudWatch();
const recipient = process.env.EMAIL_RECIPIENT;

exports.handler = async (event, context) => {
    AWSXRay.captureAWSClient(ses.service);
    try {
        const { name, email, message } = JSON.parse(event.body);
        const params = {
            Destination: { ToAddresses: [recipient] },
            Message: {
                Body: {
                    Text: { 
                        Data: `Name: ${name}\nEmail: ${email}\nMessage: ${message}` 
                    }
                },
                Subject: { Data: 'New Contact Form Submission' }
            },
            Source: recipient
        };
        await ses.sendEmail(params).promise();
        // Emit custom metric for success
        await cloudwatch.putMetricData({
            Namespace: 'ResumeWebsite',
            MetricData: [{
                MetricName: 'ContactFormSuccess',
                Value: 1,
                Unit: 'Count'
            }]
        }).promise();
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Email sent successfully' }),
            headers: { 
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST'
            }
        };
    } catch (err) {
        console.error('Error:', err);
        // Emit custom metric for error
        await cloudwatch.putMetricData({
            Namespace: 'ResumeWebsite',
            MetricData: [{
                MetricName: 'ContactFormError',
                Value: 1,
                Unit: 'Count'
            }]
        }).promise();
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message }),
            headers: { 
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST'
            }
        };
    }
};