/*
Unit tests for both Lambdas using Jest. These tests mock aws-sdk clients so no AWS calls are made.
Run with: npx jest lambda/__tests__/lambda.test.js --ci
*/

const path = require('path');

describe('visitor-counter Lambda', () => {
  beforeEach(() => {
    jest.resetModules();
    process.env.TABLE_NAME = 'TestTable';
  });

  test('increments count and returns 200 with new count', async () => {
    const mockGetPromise = jest.fn().mockResolvedValue({ Item: { count: 5 } });
    const mockPutPromise = jest.fn().mockResolvedValue({});

    jest.doMock('aws-sdk', () => ({
      DynamoDB: {
        DocumentClient: jest.fn(() => ({
          get: jest.fn(() => ({ promise: mockGetPromise })),
          put: jest.fn(() => ({ promise: mockPutPromise })),
        })),
      },
    }));

    const { handler } = require(path.join('..', 'visitor-counter', 'index.js'));
    const resp = await handler({});
    expect(resp.statusCode).toBe(200);
    const body = JSON.parse(resp.body);
    expect(body.count).toBe(6);
    expect(resp.headers['Access-Control-Allow-Origin']).toBe('*');
  });

  test('handles DynamoDB error and returns 500', async () => {
    const mockGetPromise = jest.fn().mockRejectedValue(new Error('boom'));

    jest.doMock('aws-sdk', () => ({
      DynamoDB: {
        DocumentClient: jest.fn(() => ({
          get: jest.fn(() => ({ promise: mockGetPromise })),
          put: jest.fn(() => ({ promise: jest.fn() })),
        })),
      },
    }));

    const { handler } = require(path.join('..', 'visitor-counter', 'index.js'));
    const resp = await handler({});
    expect(resp.statusCode).toBe(500);
    const body = JSON.parse(resp.body);
    expect(body.error).toBeDefined();
    expect(resp.headers['Access-Control-Allow-Origin']).toBe('*');
  });
});

describe('contact-form Lambda', () => {
  beforeEach(() => {
    jest.resetModules();
    process.env.EMAIL_RECIPIENT = 'test@example.com';
  });

  test('sends email and returns 200', async () => {
    const mockSendPromise = jest.fn().mockResolvedValue({ MessageId: '123' });

    jest.doMock('aws-sdk', () => ({
      SES: jest.fn(() => ({
        sendEmail: jest.fn(() => ({ promise: mockSendPromise })),
      })),
    }));

    const { handler } = require(path.join('..', 'contact-form', 'index.js'));
    const event = { body: JSON.stringify({ name: 'A', email: 'a@b.com', message: 'Hello' }) };
    const resp = await handler(event);
    expect(resp.statusCode).toBe(200);
    const body = JSON.parse(resp.body);
    expect(body.message).toMatch(/Email sent successfully/i);
    expect(resp.headers['Access-Control-Allow-Origin']).toBe('*');
  });

  test('handles SES error and returns 500', async () => {
    const mockSendPromise = jest.fn().mockRejectedValue(new Error('ses fail'));

    jest.doMock('aws-sdk', () => ({
      SES: jest.fn(() => ({
        sendEmail: jest.fn(() => ({ promise: mockSendPromise })),
      })),
    }));

    const { handler } = require(path.join('..', 'contact-form', 'index.js'));
    const event = { body: JSON.stringify({ name: 'A', email: 'a@b.com', message: 'Hello' }) };
    const resp = await handler(event);
    expect(resp.statusCode).toBe(500);
    const body = JSON.parse(resp.body);
    expect(body.error).toBeDefined();
    expect(resp.headers['Access-Control-Allow-Origin']).toBe('*');
  });
});
