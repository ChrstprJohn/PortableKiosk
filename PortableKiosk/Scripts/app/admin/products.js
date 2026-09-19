(function () {
    'use strict';

    var existingSizeKeys = [];

    function findControl(idSuffix) {
        return document.querySelector('[id$="' + idSuffix + '"]');
    }

    function getProductName(button) {
        var card = button ? button.closest('.card') : null;
        var heading = card ? card.querySelector('.card-header h5') : null;
        return heading ? heading.textContent.trim() : 'Selected product';
    }

    function getExistingSizeKeys(button) {
        var card = button ? button.closest('[data-existing-size-keys]') : null;
        var keys = card ? card.dataset.existingSizeKeys : '';
        return (keys || '').split(',').filter(Boolean);
    }

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
                    if (!option.dataset.baseLabel) {
                        option.dataset.baseLabel = option.textContent;
                    }

                    var isAlreadyAdded = Boolean(
                        option.value &&
                        existingSizeKeys.indexOf(option.value) !== -1
                    );
                    var isChosenInAnotherRow = Boolean(
                        option.value &&
                        option.value !== currentValue &&
                        chosenSizes.indexOf(option.value) !== -1
                    );

                    option.disabled = isAlreadyAdded || isChosenInAnotherRow;
                    option.textContent = option.dataset.baseLabel +
                        (isAlreadyAdded ? ' (already added)' : '');
                });
            }
        });

        var addButton = document.getElementById('btnAddAnotherVariant');
        if (addButton) {
            var availableVariantCount =
                Math.max(0, rows.length - existingSizeKeys.length);
            addButton.disabled =
                visibleRows.length >= availableVariantCount;
        }

        var existingNotice =
            document.getElementById('existingVariantNotice');
        if (existingNotice) {
            existingNotice.classList.toggle(
                'd-none',
                existingSizeKeys.length === 0
            );
        }
    }

    function resetVariantRows() {
        getRows().forEach(function (row, index) {
            resetRow(row);
            row.classList.toggle('d-none', index !== 0);
        });

        refreshRows();
    }

    window.openAddVariantModal = function (
        productId,
        productName,
        existingSizes
    ) {
        var hfId = document.querySelector('[id$="hfModalProductID"]');
        var displaySpan = document.getElementById('modalDisplayProductName');

        existingSizeKeys = (existingSizes || '').split(',').filter(Boolean);

        if (hfId) {
            hfId.value = productId;
        }

        if (displaySpan) {
            displaySpan.innerText = productName + ' (ID #' + productId + ')';
        }

        resetVariantRows();
    };

    window.openEditVariantModal = function (
        button,
        variantId,
        sizeKey,
        sizeName,
        price,
        isAvailable,
        imageUrl
    ) {
        var id = findControl('hfEditVariantID');
        var size = findControl('ddlEditVariantSize');
        var priceInput = findControl('txtEditVariantPrice');
        var available = findControl('chkEditVariantIsAvailable');
        var upload = findControl('uploadEditVariantImage');
        var productName = document.getElementById('editVariantProductName');
        var preview = document.getElementById('editVariantImagePreview');
        var image = document.getElementById('editVariantCurrentImage');
        var productLabel = getProductName(button);
        var productSizeKeys = getExistingSizeKeys(button);

        if (id) id.value = variantId;
        if (priceInput) priceInput.value = price;
        if (available) available.checked = isAvailable;
        if (upload) upload.value = '';
        if (productName) {
            productName.textContent = productLabel + ' — ' + sizeName;
        }

        if (size) {
            Array.from(size.options).forEach(function (option) {
                if (!option.dataset.baseLabel) {
                    option.dataset.baseLabel = option.textContent;
                }

                var isUsedByAnotherVariant = Boolean(
                    option.value &&
                    option.value !== sizeKey &&
                    productSizeKeys.indexOf(option.value) !== -1
                );

                option.disabled = isUsedByAnotherVariant;
                option.textContent = option.dataset.baseLabel +
                    (isUsedByAnotherVariant ? ' (already added)' : '');
            });

            size.value = sizeKey;
        }

        if (preview && image) {
            preview.classList.toggle('d-none', !imageUrl);
            image.src = imageUrl || '';
        }
    };

    window.openDeleteVariantModal = function (
        button,
        variantId,
        sizeName
    ) {
        var id = findControl('hfDeleteVariantID');
        var name = document.getElementById('deleteVariantName');

        if (id) id.value = variantId;
        if (name) {
            name.textContent =
                getProductName(button) + ' — ' + sizeName;
        }
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
