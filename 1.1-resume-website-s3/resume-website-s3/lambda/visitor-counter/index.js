
const AWSXRay = require('aws-xray-sdk');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const cloudwatch = new AWS.CloudWatch();
const tableName = process.env.TABLE_NAME;

exports.handler = async (event, context) => {
    AWSXRay.captureAWSClient(dynamoDB.service);
    try {
        // Get current count
        const getParams = {
            TableName: tableName,
            Key: { id: 'resume' }
        };
        const data = await dynamoDB.get(getParams).promise();
        let count = data.Item ? data.Item.count : 0;
        // Increment count
        count++;
        // Update count
        const putParams = {
            TableName: tableName,
            Item: { id: 'resume', count: count }
        };
        await dynamoDB.put(putParams).promise();
        // Emit custom metric for success
        await cloudwatch.putMetricData({
            Namespace: 'ResumeWebsite',
            MetricData: [{
                MetricName: 'VisitorCounterSuccess',
                Value: 1,
                Unit: 'Count'
            }]
        }).promise();
        return {
            statusCode: 200,
            body: JSON.stringify({ count: count }),
            headers: { 'Access-Control-Allow-Origin': '*' }
        };
    } catch (err) {
        console.error('Error:', err);
        // Emit custom metric for error
        await cloudwatch.putMetricData({
            Namespace: 'ResumeWebsite',
            MetricData: [{
                MetricName: 'VisitorCounterError',
                Value: 1,
                Unit: 'Count'
            }]
        }).promise();
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message }),
            headers: { 'Access-Control-Allow-Origin': '*' }
        };
    }
};