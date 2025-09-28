#!/bin/bash

# Image Text Extraction & Display - cURL Examples
# This script demonstrates how to extract text from images and retrieve both
# the original image and extracted text using cURL commands.

# Configuration
API_BASE_URL="http://localhost:8000"
IMAGE_FILE="test_image.png"  # Update this to your image file path

echo "🖼️  Image Text Extraction & Display - cURL Examples"
echo "=================================================="

# Function to make API calls and display results
make_request() {
    local description="$1"
    local url="$2"
    local method="$3"
    local data="$4"
    local file_param="$5"
    
    echo ""
    echo "📋 $description"
    echo "----------------------------------------"
    
    if [ "$method" = "POST" ] && [ -n "$file_param" ]; then
        # File upload
        echo "🔗 URL: $url"
        echo "📁 File: $file_param"
        echo "📤 Request:"
        echo "curl -X POST \"$url\" -F \"file=@$file_param\""
        echo ""
        echo "📥 Response:"
        curl -X POST "$url" -F "file=@$file_param" | jq '.' 2>/dev/null || curl -X POST "$url" -F "file=@$file_param"
        
    elif [ "$method" = "POST" ] && [ -n "$data" ]; then
        # JSON data
        echo "🔗 URL: $url"
        echo "📤 Request Body:"
        echo "$data" | jq '.' 2>/dev/null || echo "$data"
        echo ""
        echo "📥 Response:"
        curl -X POST "$url" \
             -H "Content-Type: application/json" \
             -d "$data" | jq '.' 2>/dev/null || curl -X POST "$url" -H "Content-Type: application/json" -d "$data"
             
    else
        # GET request
        echo "🔗 URL: $url"
        echo "📥 Response:"
        curl "$url" | jq '.' 2>/dev/null || curl "$url"
    fi
}

# Example 1: Health Check
make_request "Health Check" \
    "$API_BASE_URL/health" \
    "GET"

# Example 2: Upload Image File and Extract Text
if [ -f "$IMAGE_FILE" ]; then
    make_request "Upload Image File and Extract Text" \
        "$API_BASE_URL/ocr/upload" \
        "POST" \
        "" \
        "$IMAGE_FILE"
else
    echo ""
    echo "⚠️  Image file not found: $IMAGE_FILE"
    echo "Please update the IMAGE_FILE variable with a valid image path"
    echo ""
    echo "📝 Example with a different file:"
    echo "curl -X POST \"$API_BASE_URL/ocr/upload\" -F \"file=@your_image.png\""
fi

# Example 3: Extract Text from Base64 Image
echo ""
echo "🔗 Example 3: Extract Text from Base64 Image"
echo "----------------------------------------"

# Create a simple base64 encoded image (1x1 pixel PNG)
SAMPLE_BASE64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

BASE64_DATA=$(cat <<EOF
{
    "image": "$SAMPLE_BASE64"
}
EOF
)

make_request "Extract Text from Base64 Image" \
    "$API_BASE_URL/ocr/base64" \
    "POST" \
    "$BASE64_DATA"

# Example 4: Get Document by ID (with image data)
echo ""
echo "🔗 Example 4: Retrieve Document with Original Image"
echo "------------------------------------------------"

# Note: You'll need to replace DOCUMENT_ID with an actual document ID from a previous request
DOCUMENT_ID="your_document_id_here"

echo "📋 Retrieve Document with Original Image"
echo "----------------------------------------"
echo "🔗 URL: $API_BASE_URL/documents/$DOCUMENT_ID?include_base64=true"
echo "📥 Response:"
echo "curl \"$API_BASE_URL/documents/$DOCUMENT_ID?include_base64=true\""
echo ""
echo "⚠️  Note: Replace 'your_document_id_here' with an actual document ID from a previous OCR request"

# Example 5: Get Supported Formats
make_request "Get Supported File Formats" \
    "$API_BASE_URL/ocr/enhanced/formats" \
    "GET"

# Example 6: Get Supported Languages
make_request "Get Supported Languages" \
    "$API_BASE_URL/ocr/languages" \
    "GET"

# Example 7: Complete Workflow Script
echo ""
echo "🎯 Complete Workflow Example"
echo "============================"
echo ""
echo "Here's a complete workflow to extract text and retrieve the image:"
echo ""
echo "# Step 1: Upload image and extract text"
echo "RESPONSE=\$(curl -X POST \"$API_BASE_URL/ocr/upload\" -F \"file=@$IMAGE_FILE\")"
echo "echo \"\$RESPONSE\" | jq '.'"
echo ""
echo "# Step 2: Extract document ID from response"
echo "DOCUMENT_ID=\$(echo \"\$RESPONSE\" | jq -r '.document_id')"
echo "echo \"Document ID: \$DOCUMENT_ID\""
echo ""
echo "# Step 3: Retrieve document with original image"
echo "DOCUMENT_DATA=\$(curl \"$API_BASE_URL/documents/\$DOCUMENT_ID?include_base64=true\")"
echo "echo \"\$DOCUMENT_DATA\" | jq '.'"
echo ""
echo "# Step 4: Save the original image"
echo "echo \"\$DOCUMENT_DATA\" | jq -r '.document.base64_data' | base64 -d > original_image.png"
echo ""
echo "# Step 5: Extract just the text"
echo "echo \"\$RESPONSE\" | jq -r '.extracted_text' > extracted_text.txt"
echo ""

# Example 8: Webhook Test
make_request "Test Webhook" \
    "$API_BASE_URL/webhook/test" \
    "POST"

# Example 9: Get Webhook Status
make_request "Get Webhook Status" \
    "$API_BASE_URL/webhook/status" \
    "GET"

echo ""
echo "✅ All examples completed!"
echo ""
echo "📚 Additional Resources:"
echo "  - HTML Demo: Open image_text_extraction_solution.html in your browser"
echo "  - Python Client: Run python_client_example.py"
echo "  - API Documentation: Visit $API_BASE_URL/docs"
echo ""
echo "🔧 Tips:"
echo "  - Replace localhost:8000 with your actual API URL"
echo "  - Update IMAGE_FILE variable with your image path"
echo "  - Use jq for better JSON formatting (install with: brew install jq or apt-get install jq)"
echo "  - Check the API logs for detailed processing information"
