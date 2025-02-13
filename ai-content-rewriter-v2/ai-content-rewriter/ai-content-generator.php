<?php
/**
 * Plugin Name: AI Content Rewriter
 * Description: A WordPress plugin that rewrites content using OpenAI's API based on brand tone.
 * Version: 2.0.0
 * Author: Danny Landa
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly.
}

class AI_Content_Rewriter {
    private $option_name = 'ai_content_rewriter_settings';
    private $log_file;

    public function __construct() {
        $this->log_file = plugin_dir_path(__FILE__) . 'error_log.txt';
        add_action('admin_menu', [$this, 'create_admin_menu']);
        add_action('admin_init', [$this, 'register_settings']);
        add_action('admin_enqueue_scripts', [$this, 'enqueue_scripts']);
        add_action('admin_footer', [$this, 'render_rewriter_panel']);
        add_action('wp_ajax_rewrite_content', [$this, 'rewrite_content']);
    }

    public function create_admin_menu() {
        add_menu_page('AI Rewriter', 'AI Rewriter', 'manage_options', 'ai_rewriter', [$this, 'admin_settings_page'], 'dashicons-admin-generic');
    }

    public function register_settings() {
        register_setting('ai_rewriter_group', $this->option_name);
    }

    public function admin_settings_page() {
        $options = get_option($this->option_name);
        ?>
        <div class="wrap">
            <h1>AI Content Rewriter Settings</h1>
            <form method="post" action="options.php">
                <?php settings_fields('ai_rewriter_group'); ?>
                <table class="form-table">
                    <tr>
                        <th>OpenAI API Key:</th>
                        <td><input type="text" name="<?php echo $this->option_name; ?>[api_key]" value="<?php echo esc_attr($options['api_key'] ?? ''); ?>" size="50"></td>
                    </tr>
                    <tr>
                        <th>Default Tone:</th>
                        <td>
                            <select name="<?php echo $this->option_name; ?>[tone]">
                                <option value="professional" <?php selected($options['tone'], 'professional'); ?>>Professional</option>
                                <option value="casual" <?php selected($options['tone'], 'casual'); ?>>Casual</option>
                                <option value="friendly" <?php selected($options['tone'], 'friendly'); ?>>Friendly</option>
                            </select>
                        </td>
                    </tr>
                </table>
                <?php submit_button(); ?>
            </form>
        </div>
        <?php
    }

    public function enqueue_scripts($hook) {
        if ($hook !== 'toplevel_page_ai_rewriter') return;
        wp_enqueue_script('ai-rewriter-script', plugins_url('script.js', __FILE__), ['jquery'], null, true);
    }

    public function render_rewriter_panel() {
        if (get_current_screen()->id !== 'toplevel_page_ai_rewriter') return;
        ?>
        <div id="ai-rewriter-panel" style="position: fixed; right: 20px; top: 100px; width: 300px; background: #fff; padding: 15px; border: 1px solid #ccc; box-shadow: 2px 2px 5px rgba(0,0,0,0.1);">
            <h3>AI Content Rewriter</h3>
            <textarea id="input_content" rows="5" style="width: 100%;"></textarea>
            <button id="rewrite_button" style="margin-top: 10px;">Rewrite</button>
            <p><strong>Rewritten Content:</strong></p>
            <div id="rewritten_content"></div>
        </div>
        <script>
            jQuery(document).ready(function($) {
                $('#rewrite_button').click(function() {
                    let content = $('#input_content').val();
                    $.post(ajaxurl, { action: 'rewrite_content', content: content }, function(response) {
                        $('#rewritten_content').text(response.data.rewritten || 'Error rewriting content');
                    });
                });
            });
        </script>
        <?php
    }

    public function rewrite_content() {
        $options = get_option($this->option_name);
        $api_key = $options['api_key'] ?? '';
        $tone = $options['tone'] ?? 'professional';
        $content = sanitize_text_field($_POST['content'] ?? '');

        if (!$api_key || !$content) {
            error_log("[AI Rewriter] Missing API key or content", 3, $this->log_file);
            wp_send_json_error(['error' => 'Missing API key or content.']);
        }

        // Updated endpoint for gpt-3.5-turbo model
        $response = wp_remote_post('https://api.openai.com/v1/chat/completions', [
            'headers' => [
                'Authorization' => 'Bearer ' . $api_key,
                'Content-Type' => 'application/json'
            ],
            'body' => json_encode([
                'model' => 'gpt-3.5-turbo', // Using gpt-3.5-turbo as per your request
                'messages' => [
                    ['role' => 'system', 'content' => 'You are a helpful assistant.'],
                    ['role' => 'user', 'content' => "Rewrite the following in a " . $tone . " tone: " . $content]
                ],
                'max_tokens' => 200
            ])
        ]);

        if (is_wp_error($response)) {
            error_log("[AI Rewriter] API Request Failed: " . $response->get_error_message(), 3, $this->log_file);
            wp_send_json_error(['error' => 'Failed to contact OpenAI.']);
        }

        $body = json_decode(wp_remote_retrieve_body($response), true);
        $rewritten = $body['choices'][0]['message']['content'] ?? '';

        if (!$rewritten) {
            error_log("[AI Rewriter] Empty response from OpenAI", 3, $this->log_file);
            wp_send_json_error(['error' => 'Failed to get response from OpenAI.']);
        }

        wp_send_json_success(['rewritten' => $rewritten]);
    }
}

new AI_Content_Rewriter();
