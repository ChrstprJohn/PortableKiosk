(function () {
    'use strict';

    function getRows() {
        return Array.from(document.querySelectorAll('.bulk-variant-row'));
    }

    function resetRow(row) {
        var size = row.querySelector('.bulk-variant-size');
        var price = row.querySelector('.bulk-variant-price');
        var image = row.querySelector('.bulk-variant-image');

        if (size) {
            size.value = '';
        }

        if (price) {
            price.value = '';
        }

        if (image) {
            image.value = '';
        }
    }

    function refreshRows() {
        var rows = getRows();
        var visibleRows = rows.filter(function (row) {
            return !row.classList.contains('d-none');
        });
        var chosenSizes = visibleRows.map(function (row) {
            var size = row.querySelector('.bulk-variant-size');
            return size ? size.value : '';
        }).filter(Boolean);

        visibleRows.forEach(function (row, index) {
            var number = row.querySelector('.bulk-variant-number');
            var remove = row.querySelector('.bulk-variant-remove');
            var size = row.querySelector('.bulk-variant-size');
            var currentValue = size ? size.value : '';

            if (number) {
                number.textContent = index + 1;
            }

            if (remove) {
                remove.classList.toggle('d-none', visibleRows.length === 1);
            }

            if (size) {
                Array.from(size.options).forEach(function (option) {
                    option.disabled = Boolean(
                        option.value &&
                        option.value !== currentValue &&
                        chosenSizes.indexOf(option.value) !== -1
                    );
                });
            }
        });

        var addButton = document.getElementById('btnAddAnotherVariant');
        if (addButton) {
            addButton.disabled = visibleRows.length >= rows.length;
        }
    }

    function resetVariantRows() {
        getRows().forEach(function (row, index) {
            resetRow(row);
            row.classList.toggle('d-none', index !== 0);
        });

        refreshRows();
    }

    window.openAddVariantModal = function (productId, productName) {
        var hfId = document.querySelector('[id$="hfModalProductID"]');
        var displaySpan = document.getElementById('modalDisplayProductName');

        if (hfId) {
            hfId.value = productId;
        }

        if (displaySpan) {
            displaySpan.innerText = productName + ' (ID #' + productId + ')';
        }

        resetVariantRows();
    };

    document.addEventListener('click', function (event) {
        var addButton = event.target.closest('#btnAddAnotherVariant');
        if (addButton) {
            var nextRow = getRows().find(function (row) {
                return row.classList.contains('d-none');
            });

            if (nextRow) {
                nextRow.classList.remove('d-none');
                refreshRows();

                var nextSize = nextRow.querySelector('.bulk-variant-size');
                if (nextSize) {
                    nextSize.focus();
                }
            }

            return;
        }

        var removeButton = event.target.closest('.bulk-variant-remove');
        if (!removeButton) {
            return;
        }

        var row = removeButton.closest('.bulk-variant-row');
        var visibleRows = getRows().filter(function (candidate) {
            return !candidate.classList.contains('d-none');
        });

        if (!row || visibleRows.length === 1) {
            return;
        }

        resetRow(row);
        row.classList.add('d-none');
        refreshRows();
    });

    document.addEventListener('change', function (event) {
        if (event.target.matches('.bulk-variant-size')) {
            refreshRows();
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        resetVariantRows();
    });
})();
