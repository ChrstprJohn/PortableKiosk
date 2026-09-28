(function () {
    'use strict';

    var existingSizeKeys = [];

    function findControl(idSuffix) {
        return document.querySelector('[id$="' + idSuffix + '"]');
    }

    function getProductName(button) {
        var card = button ? button.closest('[data-existing-size-keys]') : null;
        var heading = card ? card.querySelector('[data-product-name]') : null;
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
            return !row.classList.contains('hidden');
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
                remove.classList.toggle('hidden', visibleRows.length === 1);
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
                'hidden',
                existingSizeKeys.length === 0
            );
        }
    }

    function resetVariantRows() {
        getRows().forEach(function (row, index) {
            resetRow(row);
            row.classList.toggle('hidden', index !== 0);
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
            displaySpan.innerText = productName;
        }

        resetVariantRows();
    };

    window.openViewVariantModal = function (
        button,
        variantId,
        sizeId,
        sizeName,
        price,
        isAvailable,
        imageUrl
    ) {
        var card = button ? button.closest('[data-product-id]') : null;
        var productName = card && card.querySelector('[data-product-name]');
        var category = card && card.querySelector('[data-product-category]');
        var productStatus = card && card.querySelector('[data-product-status]');
        var imageWrap = document.getElementById('viewVariantImageWrap');
        var image = document.getElementById('viewVariantImage');
        var imageEmpty = document.getElementById('viewVariantNoImage');
        var fields = {
            product: productName ? productName.textContent.trim() : 'Selected product',
            productId: card ? card.getAttribute('data-product-id') : '',
            category: category ? category.textContent.trim() : '',
            categoryId: card ? card.getAttribute('data-category-id') : '',
            description: card ? card.getAttribute('data-product-description') || 'Not provided' : 'Not provided',
            productStatus: productStatus ? productStatus.textContent.trim() : '',
            size: sizeName,
            sizeId: sizeId || 'None',
            id: variantId,
            price: '₱' + price,
            status: isAvailable ? 'Available' : 'Unavailable'
        };

        Object.keys(fields).forEach(function (key) {
            var field = document.getElementById('viewVariant' + key.charAt(0).toUpperCase() + key.slice(1));
            if (field) field.textContent = fields[key];
        });

        if (imageWrap && image && imageEmpty) {
            imageWrap.classList.toggle('hidden', !imageUrl);
            imageEmpty.classList.toggle('hidden', Boolean(imageUrl));
            image.src = imageUrl || '';
        }

        var status = document.getElementById('viewVariantStatus');
        if (status) {
            status.textContent = fields.status;
            status.className = isAvailable
                ? 'inline-flex items-center rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700'
                : 'inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600';
        }
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
            preview.classList.toggle('hidden', !imageUrl);
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
                return row.classList.contains('hidden');
            });

            if (nextRow) {
                nextRow.classList.remove('hidden');
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
            return !candidate.classList.contains('hidden');
        });

        if (!row || visibleRows.length === 1) {
            return;
        }

        resetRow(row);
        row.classList.add('hidden');
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
