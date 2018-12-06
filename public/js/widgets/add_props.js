$(document).ready(function() {
    // HTML for additional properties
    function delete_additional_property() {
        $(this).parent("p").remove();
    }
    function add_additional_property() {
        template = $("#input_additional_prop_template").clone();
        template.find("button").click(delete_additional_property);
        template.removeAttr("id");
        template.find("input").prop('disabled', false);
        template.appendTo($("#form_additional_props"));
        template.show();
    }
    $("#button_add_property").click(add_additional_property);
});
