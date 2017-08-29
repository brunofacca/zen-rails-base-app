/*
 Zen Utils is a small library consisting of utility functions (reusable code)
 written by Bruno Facca.

 License: MIT
 */

/*jshint esversion: 6 */

// The IIFE creates a new scope so we don't pollute the global namespace.
(function () {
    "use strict";
    class Library {
        constructor() {
            this.libraryName = "Zen Utils";
            this.version = "0.1.0";
        }

        // Get the type of an object in a reliable way (typeof is NOT reliable)
        classof(obj) {
            var objClass = Object.prototype
                .toString
                .call(obj)
                .replace(/^\[object\s(.*)\]$/, "$1");
            return objClass;
        }

        // Test if array or object literal is empty
        isEmpty(obj) {
            for (var x in obj) {
                if (obj.hasOwnProperty(x)) {
                    return false;
                }
            }
            return true;
        }

        // Adds a leading zero if number < 10. Useful for formatting days,
        // months, hours and minutes < 10. Only works with positive numbers.
        pad(num) {
            return ("0"+num).slice(-2);
        }

        // Formats a date object as mm/dd/yyyy.
        dateToMDY(date) {
            var day = date.getDate();
            // Month starts at zero (e.g., January is 0)
            var month = date.getMonth() + 1;
            var year = date.getFullYear();
            return ZenUtils.pad(month) + "/" + ZenUtils.pad(day) + "/" + year;
        }

        /*
        Display Bootstrap Alerts at the top of the page (formatted the same way
        as Rail's flash messages.
        Available categories: success, info, warning and danger.
        Depends on:
        a) jQuery;
        b) Existence of a DIV with ID "flash-message".
         */
        showAlert(msg, type, autoCloseTimeMs) {
            var icon;
            switch (type) {
                case 'danger':
                    icon = 'exclamation-sign';
                    break;
                case 'success':
                    icon = 'ok';
                    break;
                default:
                    icon = 'info-sign';
            }

            // Generate HTML for the alert and append to a div with ID "flash-messages"
            let alertDiv = $(
                `<div class=\"alert-dismissable alert alert-${ type }\">
                <span class=\"glyphicon glyphicon-${ icon }\" aria-hidden=\"true\">&nbsp;</span>
            <a class=\"close\" data-dismiss=\"alert\">×</a>${ msg }</div>`
            ).appendTo('#flash-messages').hide().slideDown();

            // Scroll to the top of the page to ensure the alert is visible
            $('html, body').animate({scrollTop: 0}, 'slow');

            // If the 'autoCloseTimeMs' optional argument is supplied, close the alert
            // after the specified time (in milliseconds)
            if (typeof autoCloseTimeMs !== 'undefined') {
                return alertDiv.delay(autoCloseTimeMs).slideUp(200);
            }
        }

        handleAjaxError(jqXHR, textStatus, errorThrown) {
            var msg;
            var report = false;
            if (jqXHR.status === 0) {
                msg = 'Could not connect to server. Please check your internet' +
                    ' connection.';
            } else if (jqXHR.status === 500) {
                msg = 'Internal Server Error. Please try again later.'
                report = true;
            } else if (jqXHR.status === 404) {
                msg = 'Requested page not found.';
                report = true;
            } else if (textStatus === 'parsererror') {
                msg = 'JSON parse error.'
                report = true;
            } else if (textStatus === 'timeout') {
                msg = 'No response from the server. Please check your internet' +
                    ' connection.';
            }

            if (report) {
                msg += " Please try again and contact us if the problem persists.";
            }

            // Display Bootstrap alert
            ZenUtils.showAlert(msg, 'danger', 10000)

            console.log(`
                jqXHR.readyState: ${jqXHR.readyState}
                jqXHR.status: ${jqXHR.status}
                jqXHR.statusText: ${jqXHR.statusText}
                ----------------------------------------------------------------
                jqXHR.getAllResponseHeaders():
                ${jqXHR.getAllResponseHeaders()}
                ----------------------------------------------------------------
                jqXHR.responseText (first 200 characters):
                ${(jqXHR.responseText !== undefined) ? jqXHR.responseText
                    .substring(0, 200) : null}
                ----------------------------------------------------------------
                The context (this) of the callback contains:
                ${JSON.stringify(this, null, 4)}
                ----------------------------------------------------------------
            `);
        }
    } // end of the the Library class declaration

    // Avoid name conflicts. Define "ZenUtils" in the global object for our
    // library, unless that variable name is already taken.
    if(typeof(ZenUtils) === 'undefined') {
        window.ZenUtils = new Library();
    } else{
        console.log('Unable to initialize ' + ZenUtils.libraryName +
            ': a variable called ZenUtils is already defined.');
    }
})();
