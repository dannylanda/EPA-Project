<?php
/*
Plugin Name: AI Content Rewriter
Description: Rewrite content to match brand standards using OpenAI.
Version: 1.0
Author: Danny Landa
*/

// Adds a menu item to the WordPress admin dashboard
add_action('admin_menu', 'ai_content_rewriter_menu');

// Function to add a settings page to the WordPress admin menu
function ai_content_rewriter_menu() {
    add_menu_page(
        'AI Content Rewriter', // Title of the page
        'AI Rewriter',         // Title of the menu item
        'manage_options',      // Who can access this page (admins only)
        'ai-content-rewriter', // Unique slug
        'ai_content_rewriter_settings_page', // Function to display the page content
        'dashicons-edit'       // Icon for the menu item
    );
}

// Content for the settings page
function ai_content_rewriter_settings_page() {
    ?>
    <h1>AI Content Rewriter Settings</h1>
    <form method="post" action="options.php">
        <?php
        // Register settings fields for saving API key
        settings_fields('ai_content_rewriter_settings');
        do_settings_sections('ai-content-rewriter');
        submit_button();
        ?>
    </form>
    <?php
}

// Register settings to save the OpenAI API key
add_action('admin_init', 'ai_content_rewriter_register_settings');
function ai_content_rewriter_register_settings() {
    register_setting('ai_content_rewriter_settings', 'ai_content_rewriter_api_key');

    add_settings_section(
        'ai_content_rewriter_section',        // ID of the section
        'OpenAI API Settings',                // Title of the section
        null,                                 // Callback (can add a description if needed)
        'ai-content-rewriter'                 // Page slug
    );

    add_settings_field(
        'api_key_field',                      // ID of the field
        'OpenAI API Key',                     // Label for the field
        'ai_content_rewriter_api_key_input', // Callback to render the input field
        'ai-content-rewriter',               // Page slug
        'ai_content_rewriter_section'        // Section ID
    );
}

// Input field for the API key
function ai_content_rewriter_api_key_input() {
    $api_key = get_option('ai_content_rewriter_api_key', '');
    echo '<input type="text" name="ai_content_rewriter_api_key" value="' . esc_attr($api_key) . '" style="width: 100%;">';
}

// Function to call the OpenAI API and rewrite content
function ai_content_rewriter_rewrite($content) {
    $api_key = get_option('ai_content_rewriter_api_key');

    // If no API key is set, return the original content
    if (!$api_key) {
        return $content;
    }

    // OpenAI API endpoint
    $api_url = 'https://api.openai.com/v1/completions';

    // Prepare the API request data
    $headers = array(
        'Authorization' => 'Bearer ' . $api_key, // OpenAI authentication
        'Content-Type' => 'application/json',   // Sending JSON
    );

    $brand_tone = get_option('brand_tone', 'friendly and professional'); // Default tone
    $body = json_encode(array(
        'model' => 'text-davinci-003', // Choose an AI model
    
