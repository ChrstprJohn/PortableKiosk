(function () {
    "use strict";

    document.addEventListener("click", function (event) {
        var cancelButton = event.target.closest("[data-confirm-cancel]");

        if (!cancelButton) {
            return;
        }

        if (!window.confirm("Cancel this order and clear the cart?")) {
            event.preventDefault();
        }
    });
}());
