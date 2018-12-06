$(document).ready(function() {
    // selection in the Survey Type form
    function survey_update() {
        $('#survey_type_input_custom').hide();
        // TODO test
        switch (this.selected) {
        case 'Custom':
            $('#survey_type_input_custom').show();
            $('#resno_input_single').show();
            break;
        }
    }
    $("#select_survey_type").change(survey_update);
    survey_update.call($('#survey_type_select').filter(':first')[0]);
});
