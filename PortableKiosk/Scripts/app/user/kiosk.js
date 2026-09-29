(function () {
    "use strict";

    var confirmedCancelButton = null;

    document.addEventListener("click", function (event) {
        var target = event.target;

        if (!target || !target.closest) {
            return;
        }

        var cancelButton = target.closest("[data-confirm-cancel]");

        if (cancelButton) {
            if (confirmedCancelButton === cancelButton) {
                confirmedCancelButton = null;
                return;
            }

            event.preventDefault();
            if (window.AppModal) {
                window.AppModal.confirm({
                    title: "Cancel order?",
                    message: "This will clear your cart and end the current order.",
                    variant: "quietDanger",
                    confirmText: "Cancel order",
                    cancelText: "Keep order",
                    onConfirm: function () {
                        confirmedCancelButton = cancelButton;
                        cancelButton.click();
                    }
                });
            }
            return;
        }

        var keypadButton = target.closest("[data-table-key]");

        if (!keypadButton || !keypadButton.closest("[data-table-keypad]")) {
            return;
        }

        var input = document.getElementById("txtTableNumber");

        if (!input) {
            return;
        }

        var key = keypadButton.getAttribute("data-table-key");

        if (key === "clear") {
            input.value = "";
        } else if (key === "backspace") {
            input.value = input.value.slice(0, -1);
        } else if (/^[0-9]$/.test(key) &&
            input.value.length < (input.maxLength > 0 ? input.maxLength : 20)) {
            input.value += key;
        }
    });
}());
