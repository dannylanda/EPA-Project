# AI Content Rewriter WordPress Plugin

A WordPress plugin that uses OpenAI's API to rewrite content with customizable tone.

## Directory Structure

```
wp-content/plugins/ai-content-rewriter/
├── ai-content-rewriter.php
├── js/
│   └── air-script.js
└── README.md
```

## Manual Installation Steps

1. Create a folder called `ai-content-rewriter`
2. Copy the files into the correct structure as shown above
3. Zip the `ai-content-rewriter` folder
4. In WordPress admin, go to Plugins > Add New > Upload Plugin
5. Choose the ZIP file and click "Install Now"
6. Activate the plugin
7. Go to AI Rewriter > Settings
8. Enter your OpenAI API key
9. Select your preferred tone of voice
10. Save settings

## Requirements

- WordPress 5.0 or higher
- PHP 7.4 or higher
- OpenAI API key
- Active internet connection

## Features

- Custom admin interface in WordPress dashboard
- OpenAI API integration
- Customizable tone of voice settings
- Real-time content rewriting
- AJAX-based processing
- Error handling and user feedback
- Responsive design

## Usage

1. Navigate to "AI Rewriter" in your WordPress admin menu
2. Paste your content into the "Original Content" text area
3. Click "Rewrite Content"
4. Wait for processing
5. Your rewritten content will appear in the "Rewritten Content" text area

## Security Features

- Nonce verification for AJAX requests
- Input sanitization
- Direct file access prevention
- Proper WordPress hooks and filters usage

## About Plugin Settings

### OpenAI API Key
- Required for the plugin to function
- Must be entered in the settings page before using the plugin
- Securely stored in WordPress database
- Can be updated at any time

### Tone of Voice Options
- Professional: Best for business and formal content
- Casual: Suitable for fun and informal writing
- Friendly: Perfect for upbeat customer-facing content
- Formal: Ideal for formal writing

## Support and Updates

- Regular updates for security and functionality
- Compatible with latest WordPress versions
- Tested with major themes and plugins