$(document).ready(function() {
    // radio buttons in the World form
    function form_world_select() {
        $('#input_world_custom').hide();
        switch (this.id) {
        case 'radio_world_custom':
            $('#input_world_custom').show();
            break;
        }
    }
    $('#radio_world_default, #radio_world_mendel, #radio_world_custom').change(form_world_select);
    form_world_select.call($('#form_world input:checked').filter(':first')[0]);
});
