/*
 Zen Utils is a small library consisting of utility functions (reusable code)
 written by Bruno Facca.

 License: MIT
 */

"use strict";

// The IIFE creates a new scope so we don't pollute the global namespace.
(function zenUtils() {
  class Library {
    constructor() {
      this.libraryName = "Zen Utils";
      this.version = "0.1.1";
    }

    // Get the type of an object in a reliable way (typeof is NOT reliable)
    classof(obj) {
      return Object.prototype
        .toString
        .call(obj)
        .replace(/^\[object\s(.*)\]$/, "$1");
    }

    // Test if array, object literal or string is empty.
    // Deprecated: jQuery.isEmptyObject({}); obviates this.
    isEmpty(obj) {
      return !Object.keys(obj).length;
    }

    // Adds a leading zero if number < 10. Useful for formatting days,
    // months, hours and minutes < 10. Only works with positive numbers.
    padNumber(num) {
      return (`0${num}`).slice(-2);
    }

    // Formats a date object as mm/dd/yyyy.
    dateToMDY(date) {
      const day = date.getDate();
      // Month starts at zero (e.g., January is 0)
      const month = date.getMonth() + 1;
      const year = date.getFullYear();
      return `${this.padNumber(month)}/${this.padNumber(day)}/${year}`;
    }

    /*
    Display Bootstrap Alerts at the top of the page (formatted the same way
    as Rail's flash messages.
    Available categories: success, info, warning and danger.
    Depends on:
    a) jQuery;
    b) Existence of a DIV with ID "flash-message".
     */
    showAlert(msg, bootstrapContext, autoCloseTimeMs) {
      let icon;
      let bootstrapClass;
      bootstrapClass = bootstrapContext;

      switch (bootstrapContext) {
      case "danger":
        icon = "exclamation-sign";
        break;
      case "success":
        icon = "ok";
        break;
      case "warning":
        icon = "info-sign";
        break;
      default:
        bootstrapClass = "info";
        icon = "info-sign";
      }

      // Generate HTML for the alert and append to a div with ID
      // "flash-messages".
      const alertDiv = $(
        `<div class="alert-dismissable alert alert-${bootstrapClass}">
            <span class="glyphicon glyphicon-${icon}" aria-hidden="true">&nbsp;</span>
         <a class="close" data-dismiss="alert">×</a>${msg}</div>`
      ).appendTo("#flash-messages").hide().slideDown();

      // Scroll to the top of the page to ensure the alert is visible
      $("html, body").animate({ scrollTop: 0 }, "slow");

      // If the "autoCloseTimeMs" optional argument is supplied, close
      // the alert after the specified time (in milliseconds).
      if (typeof autoCloseTimeMs !== "undefined") {
        return alertDiv.delay(autoCloseTimeMs).slideUp(200);
      }

      return undefined;
    }

    handleAjaxError(jqXHR, textStatus, errorThrown) {
      let msg;
      let report = false;

      if (jqXHR.status === 0) {
        msg = "Could not connect to server. Please check your " +
          "internet connection.";
      } else if (jqXHR.status === 500) {
        msg = "Internal Server Error. Please try again later.";
        report = true;
      } else if (jqXHR.status === 404) {
        msg = "Requested page not found.";
        report = true;
      } else if (textStatus === "parsererror") {
        msg = "JSON parse error.";
        report = true;
      } else if (textStatus === "timeout") {
        msg = "No response from the server. Please check your " +
          "internet connection.";
      }

      if (report) {
        msg += " Please try again and contact us if the problem" +
          " persists.";
      }

      const truncatedResponseText = (jqXHR.responseText !== undefined) ?
        jqXHR.responseText.substring(0, 200) : null;

      // Display Bootstrap alert
      ZenUtils.showAlert(msg, "danger", 10000);

      const errorText = `
        jqXHR.readyState: ${jqXHR.readyState}
        jqXHR.status: ${jqXHR.status}
        jqXHR.statusText: ${jqXHR.statusText}
        ---------------------------------------------------------------
        jqXHR.getAllResponseHeaders():
        ${jqXHR.getAllResponseHeaders()}
        ---------------------------------------------------------------
        jqXHR.responseText (first 200 characters):
        ${truncatedResponseText}
        ---------------------------------------------------------------
        The context (this) of the callback contains:
        ${JSON.stringify(this, null, 4)}
        ---------------------------------------------------------------
      `;

      // Remove leading whitespaces (due to indentation) from template literal.
      console.error(errorText.replace(/^\s{8}/gm, ""));
    }
  } // end of the the Library class declaration

  // Avoid name conflicts. Define "ZenUtils" in the global object for our
  // library, unless that variable name is already taken.
  if (typeof (ZenUtils) === "undefined") {
    window.ZenUtils = new Library();
  } else {
    console.error(`Unable to initialize ${ZenUtils.libraryName}: a variable
      called ZenUtils is already defined.`);
  }
}());
