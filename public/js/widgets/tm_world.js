$(document).ready(function() {
    // radio buttons in the World form
    function form_world_select() {
        $('#world_input_custom, #world_input_mendel').hide();
        switch (this.id) {
        case 'world_radio_custom':
            $('#world_input_custom, #world_input_mendel').show();
            break;
        }
    }
    $('#world_radio_default, #world_radio_mendel, #world_radio_custom').change(form_world_select);
    form_world_select.call($('#form_world input:checked').filter(':first')[0]);
});
