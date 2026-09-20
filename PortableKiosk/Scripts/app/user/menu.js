(function () {
    "use strict";

    function getQuantityInput() {
        return document.querySelector(
            ".product-detail-page input[type='number']");
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

    function syncVariantSelection() {
        var selectedVariant = document.getElementById(
            "hfSelectedVariantID");
        var choices = document.querySelectorAll(
            "[data-variant-choice]");

        if (!selectedVariant || choices.length === 0) {
            return;
        }

        var matchingChoice = document.querySelector(
            "[data-variant-choice][value='" +
            selectedVariant.value + "']");

        (matchingChoice || choices[0]).checked = true;

        choices.forEach(function (choice) {
            choice.addEventListener("change", function () {
                if (choice.checked) {
                    selectedVariant.value = choice.value;
                }
            });
        });
    }

    syncVariantSelection();
}());
