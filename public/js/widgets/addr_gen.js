$(document).ready(function() {
    // radio buttons in the Address form
    function addr_update_kind() {
        $('#addr_radios_strategy, #addr_input_single, #addr_input_preset, #addr_input_list, #addr_input_file').hide();
        switch (this.id) {
        case 'addr_radio_single':
            $('#input_addr').show();
            break;
        case 'addr_radio_preset_list':
            $('#radios_addr_strategy, #input_addr_preset_list').show();
            break;
        case 'addr_radio_custom_list':
            $('#radios_addr_strategy, #input_addr_custom_list').show();
            break;
        case 'addr_radio_custom_file':
            $('#radios_addr_strategy, #input_addr_custom_file').show();
            break;
        }
    }
    $('#addr_radio_single, #addr_radio_preset_list, #addr_radio_custom_list, #addr_radio_custom_file').change(addr_update_kind);
    addr_update_kind.call($('#addr_radios_kind input:checked').filter(':first')[0]);

    // radio buttons in the Address strategy form
    function addr_update_strategy() {
        switch (this.id) {
        case 'addr_radio_strat_random':
        case 'addr_radio_strat_incr':
        case 'addr_radio_strat_once_per':
            break;
        }
    }
    $('#addr_radio_strat_random, #addr_radio_strat_incr, #addr_radio_strat_once_per').change(addr_update_strategy);
    addr_update_strategy.call($('#addr_radios_strategy input:checked').filter(':first')[0]);
});
