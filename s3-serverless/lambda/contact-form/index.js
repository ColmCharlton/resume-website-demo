
const AWS = require('aws-sdk');

const ses = new AWS.SES();
const recipient = process.env.EMAIL_RECIPIENT;

exports.handler = async (event, context) => {
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
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Email sent successfully', recipient }),
            headers: { 
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST'
            }
        };
    } catch (err) {
        console.error('Error:', err);
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