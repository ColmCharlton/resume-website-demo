# Frontend Documentation for Resume Website

This README provides instructions for setting up and running the frontend of the comprehensive resume website project.

## Project Structure

The frontend consists of the following files:

- **index.html**: The main HTML file that contains the structure of the resume website, including sections for the visitor counter and contact form.

## Prerequisites

- A web browser to view the website.
- An internet connection to access the APIs.

## Setup Instructions

1. **Clone the Repository**: 
   Clone the repository to your local machine using the following command:
   ```
   git clone <repository-url>
   ```

2. **Navigate to the Frontend Directory**:
   Change into the frontend directory:
   ```
   cd resume-website-s3/frontend
   ```

3. **Open the HTML File**:
   Open `index.html` in your preferred web browser. You can do this by double-clicking the file or using a local server.

4. **API Configuration**:
   Ensure that the API Gateway URLs for the visitor counter and contact form are correctly set in the `index.html` file. Replace `YOUR_API_GATEWAY_URL` with the actual endpoint.

5. **Testing**:
   - Check the visitor counter to ensure it increments correctly.
   - Test the contact form by submitting a message and verifying that it is received.

## Additional Notes

- The frontend is designed to be a static website and does not require any server-side processing.
- Ensure that CORS is properly configured on the API Gateway to allow requests from your frontend.

For any issues or contributions, please refer to the main project README or contact the project maintainer.