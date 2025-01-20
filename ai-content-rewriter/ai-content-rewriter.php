<?php
/**
 * Plugin Name: AI Content Rewriter
 * Description: A WordPress plugin that uses OpenAI to rewrite content with customizable tone.
 * Version: 1.0
 * Author: Your Name
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Add admin menu
function air_add_admin_menu() {
    add_menu_page(
        'AI Content Rewriter',
        'AI Rewriter',
        'manage_options',
        'ai-content-rewriter',
        'air_display_main_page',
        'dashicons-edit'
    );
    
    add_submenu_page(
        'ai-content-rewriter',
        'Settings',
        'Settings',
        'manage_options',
        'ai-content-rewriter-settings',
        'air_display_settings_page'
    );
}
add_action('admin_menu', 'air_add_admin_menu');

// Register settings
function air_register_settings() {
    register_setting('air_settings', 'air_openai_key');
    register_setting('air_settings', 'air_tone_of_voice');
}
add_action('admin_init', 'air_register_settings');

// Enqueue necessary scripts
function air_enqueue_scripts($hook) {
    if ('toplevel_page_ai-content-rewriter' !== $hook) {
        return;
    }
    
    wp_enqueue_script(
        'air-script',
        plugins_url('js/air-script.js', __FILE__),
        array('jquery'),
        '1.0',
        true
    );
    
    wp_localize_script('air-script', 'airAjax', array(
        'ajaxurl' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('air_nonce')
    ));
}
add_action('admin_enqueue_scripts', 'air_enqueue_scripts');

// Display main rewriter page
function air_display_main_page() {
    ?>
    <div class="wrap">
        <h1>AI Content Rewriter</h1>
        <div class="air-container">
            <div class="air-input-section">
                <h2>Original Content</h2>
                <textarea id="air-original-content" rows="10" cols="50"></textarea>
            </div>
            <div class="air-button-section">
                <button id="air-rewrite-button" class="button button-primary">Rewrite Content</button>
                <div id="air-loading" style="display:none;">Processing...</div>
            </div>
            <div class="air-output-section">
                <h2>Rewritten Content</h2>
                <textarea id="air-rewritten-content" rows="10" cols="50" readonly></textarea>
            </div>
        </div>
    </div>
    <?php
}

// Display settings page
function air_display_settings_page() {
    ?>
    <div class="wrap">
        <h1>AI Content Rewriter Settings</h1>
        <form method="post" action="options.php">
            <?php
            settings_fields('air_settings');
            do_settings_sections('air_settings');
            ?>
            <table class="form-table">
                <tr>
                    <th scope="row">OpenAI API Key</th>
                    <td>
                        <input type="text" name="air_openai_key" 
                               value="<?php echo esc_attr(get_option('air_openai_key')); ?>" 
                               class="regular-text">
                    </td>
                </tr>
                <tr>
                    <th scope="row">Tone of Voice</th>
                    <td>
                        <select name="air_tone_of_voice">
                            <option value="professional" <?php selected(get_option('air_tone_of_voice'), 'professional'); ?>>Professional</option>
                            <option value="casual" <?php selected(get_option('air_tone_of_voice'), 'casual'); ?>>Casual</option>
                            <option value="friendly" <?php selected(get_option('air_tone_of_voice'), 'friendly'); ?>>Friendly</option>
                            <option value="formal" <?php selected(get_option('air_tone_of_voice'), 'formal'); ?>>Formal</option>
                        </select>
                    </td>
                </tr>
            </table>
            <?php submit_button(); ?>
        </form>
    </div>
    <?php
}

// Handle AJAX request for content rewriting
function air_rewrite_content() {
    check_ajax_referer('air_nonce', 'nonce');
    
    $api_key = get_option('air_openai_key');
    $tone = get_option('air_tone_of_voice');
    $content = sanitize_textarea_field($_POST['content']);
    
    if (empty($api_key)) {
        wp_send_json_error('OpenAI API key is not set');
        return;
    }
    
    $response = wp_remote_post('https://api.openai.com/v1/chat/completions', array(
        'headers' => array(
            'Authorization' => 'Bearer ' . $api_key,
            'Content-Type' => 'application/json',
        ),
        'body' => json_encode(array(
            'model' => 'gpt-3.5-turbo',
            'messages' => array(
                array(
                    'role' => 'system',
                    'content' => "You are a content rewriter. Rewrite the following content in a {$tone} tone while maintaining the same meaning."
                ),
                array(
                    'role' => 'user',
                    'content' => $content
                )
            )
        ))
    ));
    
    if (is_wp_error($response)) {
        wp_send_json_error($response->get_error_message());
        return;
    }
    
    $body = json_decode(wp_remote_retrieve_body($response), true);
    
    if (isset($body['choices'][0]['message']['content'])) {
        wp_send_json_success(array(
            'rewritten_content' => $body['choices'][0]['message']['content']
        ));
    } else {
        wp_send_json_error('Failed to rewrite content');
    }
}
add_action('wp_ajax_air_rewrite_content', 'air_rewrite_content');

// Add plugin styles
function air_add_styles() {
    ?>
    <style>
        .air-container {
            max-width: 1200px;
            margin: 20px 0;
        }
        .air-input-section,
        .air-output-section {
            margin: 20px 0;
        }
        .air-button-section {
            margin: 20px 0;
        }
        #air-original-content,
        #air-rewritten-content {
            width: 100%;
            min-height: 200px;
        }
        #air-loading {
            margin-top: 10px;
            color: #666;
        }
    </style>
    <?php
}
add_action('admin_head', 'air_add_styles');