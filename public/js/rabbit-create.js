$(document).ready(function() {
    $("#select_survey_type").change(function () {
        // var case = $( "#cases option:selected" ).val();
        // if(case=="general")
        // {
        //     //show 2 form fields here and show div
        //     $("#general").show();
        // }
    });

    function form_id_select(elem) {
        $("#input_id_single, #input_id_list, #input_id_incr, #input_id_rand").hide();
        switch (elem.id) {
        case "radio_id_single":
            $("#input_id_single").show();
        case "radio_id_list":
            $("#input_id_list").show();
        case "radio_id_incr":
            $("#input_id_incr").show();
        case "radio_id_rand":
            $("#input_id_rand").show();
        }
    }

    $("#radio_id_single, #radio_id_list, #radio_id_incr, #radio_id_rand").change(function () {
        form_id_select(this);
    });

    form_id_select($("#form_id input:checked"));
});
