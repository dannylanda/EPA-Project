<?php
/**
 * Plugin Name: Simple AI Chatbot
 * Description: A simple AI chatbot using the OpenAI API.
 * Version: 1.2
 * Author: Your Name
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

// Enqueue scripts and styles for the chatbot interface
function simple_ai_chatbot_enqueue_scripts($hook) {
    if ($hook !== 'toplevel_page_simple_ai_chatbot') {
        return;
    }

    wp_enqueue_script('simple-ai-chatbot-js', plugins_url('/js/chatbot.js', __FILE__), array('jquery'), '1.2', true);
    wp_localize_script('simple-ai-chatbot-js', 'chatbot_ajax', array('ajaxurl' => admin_url('admin-ajax.php')));

    wp_enqueue_style('simple-ai-chatbot-css', plugins_url('/css/chatbot.css', __FILE__));
}
add_action('admin_enqueue_scripts', 'simple_ai_chatbot_enqueue_scripts');

// Create the admin menu
function simple_ai_chatbot_create_menu() {
    add_menu_page(
        'AI Chatbot',
        'AI Chatbot',
        'manage_options',
        'simple_ai_chatbot',
        'simple_ai_chatbot_page'
    );

    add_submenu_page(
        'simple_ai_chatbot',
        'API Key Settings',
        'API Settings',
        'manage_options',
        'simple_ai_chatbot_settings',
        'simple_ai_chatbot_settings_page'
    );
}
add_action('admin_menu', 'simple_ai_chatbot_create_menu');

// Admin page for chatbot interface
function simple_ai_chatbot_page() {
    ?>
    <div class="wrap">
        <h1>Simple AI Chatbot</h1>
        <div id="chatbot-container">
            <div id="chatbot-messages"></div>
            <input type="text" id="chatbot-input" placeholder="Ask me anything..." />
            <button id="chatbot-send">Send</button>
        </div>
    </div>
    <?php
}

// Admin page for API Key settings
function simple_ai_chatbot_settings_page() {
    if (isset($_POST['simple_ai_chatbot_api_key'])) {
        update_option('simple_ai_chatbot_api_key', sanitize_text_field($_POST['simple_ai_chatbot_api_key']));
        echo '<div class="updated"><p>API Key saved!</p></div>';
    }

    $api_key = get_option('simple_ai_chatbot_api_key');

    echo '<div class="wrap">';
    echo '<h1>OpenAI API Key Settings</h1>';
    echo '<form method="post">';
    echo '<label for="simple_ai_chatbot_api_key">OpenAI API Key:</label>';
    echo '<input type="text" id="simple_ai_chatbot_api_key" name="simple_ai_chatbot_api_key" value="' . esc_attr($api_key) . '" />';
    echo '<input type="submit" value="Save" class="button button-primary" />';
    echo '</form>';
    echo '</div>';
}

// AJAX handler for chatbot requests with error handling
function simple_ai_chatbot_handle_request() {
    $api_key = get_option('simple_ai_chatbot_api_key');
    $message = sanitize_text_field($_POST['message']);
    $log_file = plugin_dir_path(__FILE__) . 'error_log.txt';

    try {
        if (!$api_key) {
            throw new Exception('API key is not set.');
        }

        $url = (is_ssl() ? 'https://' : 'http://') . 'api.openai.com/v1/chat/completions';

        $response = wp_remote_post($url, array(
            'headers' => array(
                'Authorization' => 'Bearer ' . $api_key,
                'Content-Type' => 'application/json'
            ),
            'body' => json_encode(array(
                'model' => 'gpt-3.5-turbo',
                'messages' => array(
                    array('role' => 'user', 'content' => $message)
                )
            ))
        ));

        if (is_wp_error($response)) {
            throw new Exception('Error contacting OpenAI: ' . $response->get_error_message());
        }

        $body = json_decode(wp_remote_retrieve_body($response), true);

        if (!isset($body['choices'][0]['message']['content'])) {
            throw new Exception('Unexpected API response: ' . json_encode($body));
        }

        $answer = $body['choices'][0]['message']['content'];
        wp_send_json_success($answer);

    } catch (Exception $e) {
        // Log error to file
        error_log(date('[Y-m-d H:i:s] ') . $e->getMessage() . PHP_EOL, 3, $log_file);

        // Send error response to AJAX
        wp_send_json_error('An error occurred. Please check the error log.');
    }
}
add_action('wp_ajax_simple_ai_chatbot', 'simple_ai_chatbot_handle_request');
add_action('wp_ajax_nopriv_simple_ai_chatbot', 'simple_ai_chatbot_handle_request');