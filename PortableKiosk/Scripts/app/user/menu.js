(function () {
    "use strict";

    function getQuantityInput() {
        return document.querySelector(
            "#productModal input[type='number']");
    }

    function changeQuantity(change) {
        var input = getQuantityInput();

        if (!input) {
            return;
        }

        var currentValue = parseInt(input.value, 10);

        if (isNaN(currentValue)) {
            currentValue = 1;
        }

        input.value = Math.max(
            1,
            Math.min(99, currentValue + change));
    }

    document.addEventListener("click", function (event) {
        var control = event.target.closest("[data-quantity-action]");

        if (!control) {
            return;
        }

        changeQuantity(
            control.getAttribute("data-quantity-action") === "increase"
                ? 1
                : -1);
    });

    window.kioskMenu = {
        openProductModal: function () {
            var modalElement = document.getElementById("productModal");

            if (!modalElement || !window.bootstrap) {
                return;
            }

            window.bootstrap.Modal
                .getOrCreateInstance(modalElement)
                .show();
        }
    };
}());
