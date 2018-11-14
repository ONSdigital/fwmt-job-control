$(document).ready(function() {
    // controlling the job count form
    function job_count_update() {
        $('#job_count_form input').prop('disabled', false);
        if ($('#addr_radio_strat_once_per').is(':checked')) {
            $('#job_count_form input').val('');
            $('#job_count_form input').prop('disabled', true);
        }
    }
    $('#addr_radio_strat_random, #addr_radio_strat_incr, #addr_radio_strat_once_per').change(addr_form_update_strategy);
    job_count_update.call();
});
