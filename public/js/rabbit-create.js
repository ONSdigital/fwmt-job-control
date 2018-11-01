$(document).ready(function() {
    // selector for Survey Type
    $("#select_survey_type").change(function () {
    });

    // radio buttons in the World form
    function form_world_select() {
        $("#input_world_custom").hide();
        switch (this.id) {
        case "radio_world_custom":
            $("#input_world_custom").show();
            break;
        }
    }
    $("#radio_world_default, #radio_world_mendel, #radio_world_custom").change(form_world_select);
    form_world_select.call($("#form_world input:checked").filter(":first")[0]);

    // radio buttons in the ID form
    function form_id_select() {
        $("#input_id_single, #input_id_list, #input_id_incr, #input_id_rand").hide();
        switch (this.id) {
        case "radio_id_single":
            $("#input_id_single").show();
            break;
        case "radio_id_list":
            $("#input_id_list").show();
            break;
        case "radio_id_incr":
            $("#input_id_incr").show();
            break;
        case "radio_id_rand":
            $("#input_id_rand").show();
            break;
        }
    }
    $("#radio_id_single, #radio_id_list, #radio_id_incr, #radio_id_rand").change(form_id_select);
    form_id_select.call($("#form_id input:checked").filter(":first")[0]);

    // radio buttons in the Due Date form
    function form_due_date_select() {
        $("#input_due_date_set, #input_due_date_hours, #input_due_date_days").hide();
        switch (this.id) {
        case "radio_due_date_set":
            $("#input_due_date_set").show();
            break;
        case "radio_due_date_hours":
            $("#input_due_date_hours").show();
            break;
        case "radio_due_date_days":
            $("#input_due_date_days").show();
            break;
        }
    }
    $("#radio_due_date_set, #radio_due_date_hours, #radio_due_date_days").change(form_due_date_select);
    form_due_date_select.call($("#form_due_date input:checked").filter(":first")[0]);

    // radio buttons in the Address form
    function form_addr_select() {
        $("#radios_addr_strategy, #input_addr, #input_addr_preset_list, #input_addr_custom_list, #input_addr_custom_file").hide();
        switch (this.id) {
        case "radio_addr_single":
            $("#input_addr").show();
            break;
        case "radio_addr_preset_list":
            $("#radios_addr_strategy, #input_addr_preset_list").show();
            break;
        case "radio_addr_custom_list":
            $("#radios_addr_strategy, #input_addr_custom_list").show();
            break;
        case "radio_addr_custom_file":
            $("#radios_addr_strategy, #input_addr_custom_file").show();
            break;
        }
    }
    $("#radio_addr_single, #radio_addr_preset_list, #radio_addr_custom_list, #radio_addr_custom_file").change(form_addr_select);
    form_addr_select.call($("#radios_addr input:checked").filter(":first")[0]);

    // radio buttons in the Address strategy form
    function form_addr_strategy_select() {
        $("#form_job_count input").prop('disabled', false);
        switch (this.id) {
        case "radio_addr_strat_random":
        case "radio_addr_strat_incr":
            break;
        case "radio_addr_strat_once_per":
            $("#form_job_count input").val('');
            $("#form_job_count input").prop('disabled', true);
            break;
        }
    }
    $("#radio_addr_strat_random, #radio_addr_strat_incr, #radio_addr_strat_once_per").change(form_addr_strategy_select);
    form_addr_strategy_select.call($("#radios_addr_strategy input:checked").filter(":first")[0]);

    // HTML for additional properties
    function delete_additional_property() {
        $(this).parent("p").remove();
    }
    function add_additional_property() {
        template = $("#input_additional_prop_template").clone();
        template.find("button").click(delete_additional_property);
        template.removeAttr("id");
        template.appendTo($("#form_additional_props"));
        template.show();
    }
    $("#button_add_property").click(add_additional_property);

});
