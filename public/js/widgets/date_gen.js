$(document).ready(function() {
    // radio buttons in the Due Date form
    function due_date_update() {
        $("#due_date_input_set, #due_date_input_hours, #due_date_input_days").hide();
        switch (this.id) {
        case "due_date_radio_set":
            $("#due_date_input_set").show();
            break;
        case "due_date_radio_hours":
            $("#due_date_input_hours").show();
            break;
        case "due_date_radio_days":
            $("#due_date_input_days").show();
            break;
        }
    }
    $("#due_date_radio_set, #due_date_radio_hours, #due_date_radio_days").change(due_date_update);
    form_due_date_select.call($("#due_date_form input:checked").filter(":first")[0]);
});
