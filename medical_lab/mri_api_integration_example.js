/**
 * MRI Image Text Extraction & Display - JavaScript API Integration
 * This script demonstrates how to integrate with the Medication OCR API
 * to extract text from MRI brain scan images and display both the image and text.
 */

class MRIImageExtractor {
    constructor(apiBaseUrl = 'http://localhost:8000') {
        this.apiBaseUrl = apiBaseUrl;
        this.currentDocumentId = null;
        this.currentImageFile = null;
    }

    /**
     * Extract text from MRI image file
     * @param {File} imageFile - The MRI image file to process
     * @returns {Promise<Object>} OCR extraction results
     */
    async extractTextFromFile(imageFile) {
        try {
            console.log(`🔍 Processing MRI image: ${imageFile.name}`);
            
            const formData = new FormData();
            formData.append('file', imageFile);

            const response = await fetch(`${this.apiBaseUrl}/ocr/upload`, {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            this.currentDocumentId = result.document_id;
            
            console.log('✅ OCR processing completed:', result);
            return result;

        } catch (error) {
            console.error('❌ Error processing MRI image:', error);
            throw error;
        }
    }

    /**
     * Extract text from base64 encoded MRI image
     * @param {string} base64Data - Base64 encoded image data
     * @returns {Promise<Object>} OCR extraction results
     */
    async extractTextFromBase64(base64Data) {
        try {
            console.log('🔍 Processing base64 encoded MRI image');
            
            // Clean base64 data
            const cleanBase64 = base64Data.replace(/^data:image\/[a-z]+;base64,/, '');
            
            const payload = { image: cleanBase64 };
            
            const response = await fetch(`${this.apiBaseUrl}/ocr/base64`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            console.log('✅ Base64 OCR processing completed:', result);
            return result;

        } catch (error) {
            console.error('❌ Error processing base64 image:', error);
            throw error;
        }
    }

    /**
     * Retrieve document with original image data
     * @param {string} documentId - Document ID from OCR response
     * @returns {Promise<Object>} Document data including base64 image
     */
    async getDocumentWithImage(documentId = null) {
        try {
            const docId = documentId || this.currentDocumentId;
            if (!docId) {
                throw new Error('No document ID available');
            }

            console.log(`📄 Retrieving document: ${docId}`);
            
            const response = await fetch(`${this.apiBaseUrl}/documents/${docId}?include_base64=true`);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            console.log('✅ Document retrieved:', result);
            return result;

        } catch (error) {
            console.error('❌ Error retrieving document:', error);
            throw error;
        }
    }

    /**
     * Save image from document data to local storage
     * @param {Object} documentData - Document data containing base64 image
     * @param {string} filename - Filename for saved image
     * @returns {boolean} Success status
     */
    saveImageFromDocument(documentData, filename = 'mri_extracted_image') {
        try {
            if (!documentData.success || !documentData.document.base64_data) {
                console.error('❌ Invalid document data or missing base64 data');
                return false;
            }

            const document = documentData.document;
            const base64Data = document.base64_data;
            const fileType = document.file_type || 'image/png';

            // Create download link
            const link = document.createElement('a');
            link.href = `data:${fileType};base64,${base64Data}`;
            link.download = `${filename}.${this.getFileExtension(fileType)}`;
            
            // Trigger download
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            console.log(`✅ Image saved as: ${filename}.${this.getFileExtension(fileType)}`);
            return true;

        } catch (error) {
            console.error('❌ Error saving image:', error);
            return false;
        }
    }

    /**
     * Get file extension from MIME type
     * @param {string} mimeType - MIME type string
     * @returns {string} File extension
     */
    getFileExtension(mimeType) {
        const extensions = {
            'image/jpeg': 'jpg',
            'image/jpg': 'jpg',
            'image/png': 'png',
            'image/gif': 'gif',
            'image/bmp': 'bmp',
            'image/tiff': 'tiff',
            'image/webp': 'webp'
        };
        return extensions[mimeType] || 'png';
    }

    /**
     * Display OCR results in formatted way
     * @param {Object} ocrResult - OCR extraction result
     * @param {Object} documentData - Optional document data with image
     */
    displayResults(ocrResult, documentData = null) {
        console.log('\n' + '='.repeat(60));
        console.log('📋 MRI OCR EXTRACTION RESULTS');
        console.log('='.repeat(60));

        if (!ocrResult.success) {
            console.error(`❌ Extraction failed: ${ocrResult.error}`);
            return;
        }

        // Basic information
        console.log(`📄 Filename: ${ocrResult.filename || 'N/A'}`);
        console.log(`📊 Text Count: ${ocrResult.text_count || 0} characters`);
        console.log(`⏱️  Processing Time: ${ocrResult.processing_time || 'N/A'}`);
        console.log(`🎯 Confidence Score: ${ocrResult.confidence_score || 'N/A'}`);
        console.log(`🔧 Processing Method: ${ocrResult.processing_summary?.method || 'N/A'}`);

        // Document information
        if (documentData && documentData.success) {
            const doc = documentData.document;
            console.log(`💾 Document ID: ${doc.document_id || 'N/A'}`);
            console.log(`🏥 Patient ID: ${doc.patient_id || 'N/A'}`);
            console.log(`📁 File Type: ${doc.file_type || 'N/A'}`);
            console.log(`📏 File Size: ${this.formatFileSize(doc.file_size || 0)}`);
        }

        // Extracted text
        console.log('\n' + '-'.repeat(60));
        console.log('📝 EXTRACTED TEXT:');
        console.log('-'.repeat(60));
        const extractedText = ocrResult.extracted_text || 'No text extracted from this medical image';
        console.log(extractedText);

        // Detailed results
        console.log('\n' + '-'.repeat(60));
        console.log('📊 DETAILED RESULTS:');
        console.log('-'.repeat(60));

        const results = ocrResult.results || [];
        if (results.length > 0) {
            results.forEach((result, index) => {
                console.log(`\n🔍 Text Block ${index + 1}:`);
                console.log(`   Text: ${result.text || 'N/A'}`);
                console.log(`   Confidence: ${result.confidence || 'N/A'}`);
                console.log(`   Bounding Box: ${JSON.stringify(result.bbox || 'N/A')}`);
            });
        } else {
            console.log('No individual text blocks detected');
        }

        // Webhook status
        if (ocrResult.webhook_delivery) {
            const webhookStatus = ocrResult.webhook_delivery;
            console.log(`\n🔗 Webhook Status: ${webhookStatus.status || 'N/A'}`);
            if (webhookStatus.results && webhookStatus.results.length > 0) {
                webhookStatus.results.forEach(webhookResult => {
                    const statusIcon = webhookResult.success ? '✅' : '❌';
                    console.log(`   ${statusIcon} ${webhookResult.config_name || 'N/A'}: ${webhookResult.url || 'N/A'}`);
                });
            }
        }
    }

    /**
     * Format file size in human readable format
     * @param {number} bytes - File size in bytes
     * @returns {string} Formatted file size
     */
    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    /**
     * Complete workflow: Upload -> Extract -> Display -> Save
     * @param {File} imageFile - MRI image file to process
     * @param {boolean} saveImage - Whether to save the original image
     * @returns {Promise<Object>} Complete processing results
     */
    async completeWorkflow(imageFile, saveImage = true) {
        try {
            console.log('🚀 Starting complete MRI image processing workflow...');

            // Step 1: Extract text
            const ocrResult = await this.extractTextFromFile(imageFile);

            // Step 2: Get document data
            let documentData = null;
            if (ocrResult.success && ocrResult.document_id) {
                documentData = await this.getDocumentWithImage(ocrResult.document_id);
            }

            // Step 3: Display results
            this.displayResults(ocrResult, documentData);

            // Step 4: Save image if requested
            if (saveImage && documentData && documentData.success) {
                this.saveImageFromDocument(documentData, 'mri_original_image');
            }

            console.log('✅ Complete workflow finished successfully!');
            
            return {
                ocrResult,
                documentData,
                success: true
            };

        } catch (error) {
            console.error('❌ Complete workflow failed:', error);
            return {
                success: false,
                error: error.message
            };
        }
    }
}

// Example usage and demo functions
class MRIDemo {
    constructor() {
        this.extractor = new MRIImageExtractor();
    }

    /**
     * Demo function showing how to use the MRI Image Extractor
     */
    async runDemo() {
        console.log('🧠 MRI Image Extraction Demo');
        console.log('============================');

        // Example 1: Process a file input
        console.log('\n📁 Example 1: Processing file input');
        console.log('-'.repeat(40));

        // This would be called when a user selects a file
        // const fileInput = document.getElementById('fileInput');
        // if (fileInput.files[0]) {
        //     await this.extractor.completeWorkflow(fileInput.files[0]);
        // }

        // Example 2: Process base64 data
        console.log('\n🔗 Example 2: Processing base64 data');
        console.log('-'.repeat(40));

        // Sample base64 data (1x1 pixel PNG)
        const sampleBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        
        try {
            const result = await this.extractor.extractTextFromBase64(sampleBase64);
            this.extractor.displayResults(result);
        } catch (error) {
            console.error('Base64 processing failed:', error);
        }

        console.log('\n✅ Demo completed!');
    }

    /**
     * Setup file input handler
     * @param {string} inputId - ID of the file input element
     */
    setupFileInputHandler(inputId) {
        const fileInput = document.getElementById(inputId);
        if (!fileInput) {
            console.error(`File input with ID '${inputId}' not found`);
            return;
        }

        fileInput.addEventListener('change', async (event) => {
            const file = event.target.files[0];
            if (file) {
                console.log(`📁 File selected: ${file.name} (${this.extractor.formatFileSize(file.size)})`);
                
                try {
                    await this.extractor.completeWorkflow(file);
                } catch (error) {
                    console.error('File processing failed:', error);
                }
            }
        });
    }

    /**
     * Setup drag and drop handler
     * @param {string} dropZoneId - ID of the drop zone element
     */
    setupDragDropHandler(dropZoneId) {
        const dropZone = document.getElementById(dropZoneId);
        if (!dropZone) {
            console.error(`Drop zone with ID '${dropZoneId}' not found`);
            return;
        }

        dropZone.addEventListener('dragover', (event) => {
            event.preventDefault();
            dropZone.style.background = '#f0f8ff';
        });

        dropZone.addEventListener('dragleave', (event) => {
            event.preventDefault();
            dropZone.style.background = '';
        });

        dropZone.addEventListener('drop', async (event) => {
            event.preventDefault();
            dropZone.style.background = '';

            const files = event.dataTransfer.files;
            if (files.length > 0) {
                const file = files[0];
                console.log(`📁 File dropped: ${file.name} (${this.extractor.formatFileSize(file.size)})`);
                
                try {
                    await this.extractor.completeWorkflow(file);
                } catch (error) {
                    console.error('Drag and drop processing failed:', error);
                }
            }
        });
    }
}

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { MRIImageExtractor, MRIDemo };
}

// Auto-run demo if this script is loaded in browser
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        const demo = new MRIDemo();
        demo.runDemo();
        
        // Setup handlers if elements exist
        demo.setupFileInputHandler('mriFileInput');
        demo.setupDragDropHandler('mriDropZone');
    });
}
