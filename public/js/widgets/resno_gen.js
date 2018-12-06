$(document).ready(function() {
    // radio buttons in the Resource Number form
    function resno_update_kind() {
        $('#resno_input_single, #resno_input_list').hide();
        switch (this.id) {
        case 'resno_radio_single':
            $('#resno_input_single').show();
            break;
        case 'resno_radio_list':
            $('#resno_input_list').show();
            break;
        }
    }
    $('#resno_radio_single, #resno_radio_list').change(resno_update_kind);
    resno_update_kind.call($('#resno_radios_kind input:checked').filter(':first')[0]);
});
