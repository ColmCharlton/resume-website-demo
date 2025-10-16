from flask import render_template, request, jsonify
from app import app
from app.services.visitor_counter import increment_counter, get_count
from app.services.email_service import send_contact_email

@app.route('/')
def index():
    """Render the main resume page."""
    return render_template('index.html')

@app.route('/api/visitor', methods=['GET'])
def visitor_count():
    """
    API endpoint to get and increment visitor count.

    Returns:
        JSON response with visitor count or error message
    """
    try:
        count = increment_counter()
        return jsonify({'count': count}), 200
    except Exception as e:
        import traceback
        tb_str = traceback.format_exc()
        print(f"Error in visitor_count: {e}\n{tb_str}")
        return jsonify({'error': str(e), 'traceback': tb_str}), 500

@app.route('/api/contact', methods=['POST'])
def contact():
    """
    API endpoint to handle contact form submissions.

    Returns:
        JSON response with success message or error
    """
    try:
        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        # Extract required fields
        name = data.get('name', '').strip()
        email = data.get('email', '').strip()
        message = data.get('message', '').strip()
        
        # Validate required fields
        if not all([name, email, message]):
            return jsonify({'error': 'All fields (name, email, message) are required'}), 400
        
        # Send email
        response = send_contact_email(name, email, message)
        
        return jsonify({
            'message': 'Email sent successfully',
            'messageId': response.get('MessageId')
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        import traceback
        tb_str = traceback.format_exc()
        print(f"Error in contact: {e}\n{tb_str}")
        return jsonify({'error': str(e), 'traceback': tb_str}), 500

@app.route('/api/contact', methods=['OPTIONS'])
def contact_options():
    """Handle CORS preflight for contact endpoint."""
    response = jsonify({'message': 'OK'})
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    response.headers.add('Access-Control-Allow-Methods', 'POST,OPTIONS')
    return response

@app.route('/api/visitor', methods=['OPTIONS'])
def visitor_options():
    """Handle CORS preflight for visitor endpoint."""
    response = jsonify({'message': 'OK'})
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    response.headers.add('Access-Control-Allow-Methods', 'GET,OPTIONS')
    return response

@app.route('/health')
def health_check():
    """Health check endpoint for load balancers."""
    return jsonify({'status': 'healthy', 'service': 'resume-website-ec2'}), 200

@app.route('/debug/env')
def debug_env():
    """Debug endpoint to check environment variables."""
    import os
    env_vars = {
        'AWS_REGION': os.environ.get('AWS_REGION', 'NOT_SET'),
        'AWS_ACCESS_KEY_ID': 'SET' if os.environ.get('AWS_ACCESS_KEY_ID') else 'NOT_SET',
        'AWS_SECRET_ACCESS_KEY': 'SET' if os.environ.get('AWS_SECRET_ACCESS_KEY') else 'NOT_SET',
        'DYNAMODB_TABLE': os.environ.get('DYNAMODB_TABLE', 'NOT_SET'),
        'EMAIL_RECIPIENT': os.environ.get('EMAIL_RECIPIENT', 'NOT_SET'),
        'FLASK_ENV': os.environ.get('FLASK_ENV', 'NOT_SET')
    }
    return jsonify(env_vars), 200

# Add CORS headers to all responses
@app.after_request
def after_request(response):
    """Add CORS headers to all responses."""
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    return response