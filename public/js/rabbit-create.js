$(document).ready(function() {
    $("#select_survey_type").change(function () {
        // var case = $( "#cases option:selected" ).val();
        // if(case=="general")
        // {
        //     //show 2 form fields here and show div
        //     $("#general").show();
        // }
    });

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
        console.log("Run");
        $("#radios_addr_strategy, #input_addr, #input_addr_preset_list, #input_addr_custom_list").hide();
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
        }
    }
    $("#radio_addr_single, #radio_addr_preset_list, #radio_addr_custom_list").change(form_addr_select);
    form_addr_select.call($("#radios_addr input:checked").filter(":first")[0]);

    // radio buttons in the Address strategy form
    function form_addr_select_strategy() {
    }
    $("#radio_addr_strat_random, #radio_addr_strat_incr, #radio_addr_strat_once_per").change(form_addr_select_strategy);
    form_addr_select_strategy.call($("#radios_addr_strategy input:checked").filter(":first")[0]);

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
