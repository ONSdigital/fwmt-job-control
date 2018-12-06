$(document).ready(function() {
    // radio buttons in the ID form
    function id_update() {
        $("#id_input_single, #id_input_list, #id_input_incr, #id_input_rand").hide();
        switch (this.id) {
        case "id_radio_single":
            $("#id_input_single").show();
            break;
        case "id_radio_list":
            $("#id_input_list").show();
            break;
        case "id_radio_incr":
            $("#id_input_incr").show();
            break;
        case "id_radio_rand":
            $("#id_input_rand").show();
            break;
        }
    }
    $("#id_radio_single, #id_radio_list, #id_radio_incr, #id_radio_rand").change(id_update);
    id_update.call($("#id_form input:checked").filter(":first")[0]);
});
