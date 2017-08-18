// This file contains JS code which is used across the entire Rails application.

$(document).on("turbolinks:load", function() {
    // Bootstrap tooltips
    $('[data-toggle="tooltip"]').tooltip();

    // Select2 dropdowns
    $('.select2-dropdown').select2();
});
