
const AWS = require('aws-sdk');

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.TABLE_NAME;

exports.handler = async (event, context) => {
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
        return {
            statusCode: 200,
            body: JSON.stringify({ count: count }),
            headers: { 'Access-Control-Allow-Origin': '*' }
        };
    } catch (err) {
        console.error('Error:', err);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message }),
            headers: { 'Access-Control-Allow-Origin': '*' }
        };
    }
};