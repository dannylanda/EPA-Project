jQuery(document).ready(function ($) {
    $('#chatbot-send').on('click', function () {
        let message = $('#chatbot-input').val();
        if (message.trim() === '') {
            return;
        }

        $('#chatbot-messages').append('<div class="user-message">' + message + '</div>');
        $('#chatbot-input').val('');

        $.ajax({
            url: chatbot_ajax.ajaxurl,
            method: 'POST',
            data: {
                action: 'simple_ai_chatbot',
                message: message
            },
            success: function (response) {
                if (response.success) {
                    $('#chatbot-messages').append('<div class="bot-message">' + response.data + '</div>');
                } else {
                    $('#chatbot-messages').append('<div class="bot-message">Sorry, something went wrong.</div>');
                }
            }
        });
    });
});
