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

        if (hfId) {
            hfId.value = productId;
        }

        if (displaySpan) {
            displaySpan.innerText = productName + ' (ID #' + productId + ')';
        }
    };
})();
