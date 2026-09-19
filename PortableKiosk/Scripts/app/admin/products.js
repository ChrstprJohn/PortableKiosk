(function () {
    'use strict';

    /**
     * Pre-populates the Add Variant modal with target Product information.
     * @param {number|string} productId - Target Product ID
     * @param {string} productName - Target Product Name
     */
    window.openAddVariantModal = function (productId, productName) {
        var hfId = document.querySelector('[id$="hfModalProductID"]');
        var displaySpan = document.getElementById('modalDisplayProductName');
        var rows = document.querySelectorAll('.bulk-variant-row');

        if (hfId) {
            hfId.value = productId;
        }

        if (displaySpan) {
            displaySpan.innerText = productName + ' (ID #' + productId + ')';
        }

        rows.forEach(function (row) {
            var checkbox = row.querySelector('input[type="checkbox"]');
            var price = row.querySelector('.bulk-variant-price');

            if (checkbox) {
                checkbox.checked = false;
            }

            if (price) {
                price.value = '';
                price.readOnly = true;
            }

            row.classList.remove('bg-primary-subtle');
        });
    };

    document.addEventListener('change', function (event) {
        if (!event.target.matches('.bulk-variant-row input[type="checkbox"]')) {
            return;
        }

        var row = event.target.closest('.bulk-variant-row');
        var price = row ? row.querySelector('.bulk-variant-price') : null;
        var selected = event.target.checked;

        if (price) {
            price.readOnly = !selected;

            if (selected) {
                price.focus();
            } else {
                price.value = '';
            }
        }

        if (row) {
            row.classList.toggle('bg-primary-subtle', selected);
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.bulk-variant-price').forEach(function (price) {
            price.readOnly = true;
        });
    });
})();
