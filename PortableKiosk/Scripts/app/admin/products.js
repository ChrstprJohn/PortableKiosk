(function () {
    'use strict';

    var existingSizeKeys = [];
    var editVariantPreviewUrl = null;

    function initializeProductFilters() {
        var search = document.getElementById('productSearch');
        var category = document.getElementById('productCategoryFilter');
        var availability = document.getElementById('productAvailabilityFilter');
        var count = document.getElementById('productResultCount');
        var clear = document.getElementById('clearProductFilters');
        var empty = document.getElementById('noProductMatches');
        var reset = document.getElementById('resetProductFilters');
        if (!search || !category || !availability || !count || !clear || !empty || !reset) return;

        var groups = Array.from(document.querySelectorAll('[data-product-group]'));
        var products = [];
        var storageKey = 'admin-product-filters:' + window.location.pathname;

        function normalize(value) {
            return (value || '').toLocaleLowerCase().replace(/\s+/g, ' ').trim();
        }

        groups.forEach(function (group) {
            var option = document.createElement('option');
            option.value = group.dataset.categoryId;
            option.textContent = group.querySelector('h2').textContent.trim();
            category.appendChild(option);

            Array.from(group.querySelectorAll('[data-product-result]')).forEach(function (result) {
                var card = result.querySelector('[data-product-id]');
                var sizes = Array.from(card.querySelectorAll('[data-variant-size]')).map(function (size) {
                    return size.textContent;
                }).join(' ');
                products.push({
                    result: result,
                    group: group,
                    categoryId: card.dataset.productCategoryId,
                    available: normalize(card.dataset.productAvailable),
                    text: normalize(card.querySelector('[data-product-name]').textContent + ' ' +
                        card.dataset.productDescription + ' ' + card.dataset.productCategory + ' ' + sizes)
                });
            });
        });

        // Keep the current view after editing a product or variant in this tab.
        try {
            var saved = JSON.parse(window.sessionStorage.getItem(storageKey) || 'null');
            if (saved) {
                search.value = typeof saved.search === 'string' ? saved.search.slice(0, 150) : '';
                category.value = typeof saved.category === 'string' ? saved.category : '';
                availability.value = typeof saved.availability === 'string' ? saved.availability : '';
                if (category.selectedIndex < 0) category.value = '';
                if (availability.selectedIndex < 0) availability.value = '';
            }
        } catch (error) {
            // Filtering still works when browser storage is unavailable.
        }

        function applyFilters() {
            var terms = normalize(search.value).split(' ').filter(Boolean);
            var visibleCount = 0;
            var visibleGroups = new Set();

            products.forEach(function (product) {
                var matches = (!category.value || product.categoryId === category.value) &&
                    (!availability.value || product.available === availability.value) &&
                    terms.every(function (term) { return product.text.indexOf(term) !== -1; });
                product.result.hidden = !matches;
                if (matches) {
                    visibleCount += 1;
                    visibleGroups.add(product.group);
                }
            });

            groups.forEach(function (group) { group.hidden = !visibleGroups.has(group); });
            count.textContent = 'Showing ' + visibleCount + ' of ' + products.length +
                (products.length === 1 ? ' product' : ' products');
            clear.hidden = !terms.length && !category.value && !availability.value;
            empty.hidden = visibleCount > 0 || products.length === 0;

            try {
                window.sessionStorage.setItem(storageKey, JSON.stringify({
                    search: search.value,
                    category: category.value,
                    availability: availability.value
                }));
            } catch (error) {
                // Browser storage is optional.
            }
        }

        function clearFilters() {
            search.value = '';
            category.value = '';
            availability.value = '';
            applyFilters();
            search.focus();
        }

        search.addEventListener('input', applyFilters);
        search.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') event.preventDefault();
        });
        category.addEventListener('change', applyFilters);
        availability.addEventListener('change', applyFilters);
        clear.addEventListener('click', clearFilters);
        reset.addEventListener('click', clearFilters);
        applyFilters();
    }

    function findControl(idSuffix) {
        return document.querySelector('[id$="' + idSuffix + '"]');
    }

    function getProductCard(button) {
        return button ? button.closest('[data-existing-size-keys]') : null;
    }

    function getProductName(button) {
        var card = getProductCard(button);
        var heading = card ? card.querySelector('[data-product-name]') : null;
        return heading ? heading.textContent.trim() : 'Selected product';
    }

    function getExistingSizeKeys(button) {
        var card = getProductCard(button);
        var keys = card ? card.dataset.existingSizeKeys : '';
        return (keys || '').split(',').filter(Boolean);
    }

    function releaseEditVariantPreviewUrl() {
        if (editVariantPreviewUrl) {
            window.URL.revokeObjectURL(editVariantPreviewUrl);
            editVariantPreviewUrl = null;
        }
    }

    function clearBulkVariantImagePreview(input) {
        var previewUrl = input.dataset.previewUrl;
        var row = input.closest('.bulk-variant-row');
        var preview = row && row.querySelector('.bulk-variant-image-preview');
        var empty = row && row.querySelector('.bulk-variant-image-empty');

        if (previewUrl) {
            window.URL.revokeObjectURL(previewUrl);
            delete input.dataset.previewUrl;
        }

        if (preview) {
            preview.src = '';
            preview.classList.add('hidden');
        }

        if (empty) {
            empty.classList.remove('hidden');
        }
    }

    function updateBulkVariantImagePreview(input) {
        clearBulkVariantImagePreview(input);

        var file = input.files && input.files[0];
        if (!file) return;

        var row = input.closest('.bulk-variant-row');
        var preview = row && row.querySelector('.bulk-variant-image-preview');
        var empty = row && row.querySelector('.bulk-variant-image-empty');
        if (!preview || !empty) return;

        var previewUrl = window.URL.createObjectURL(file);
        input.dataset.previewUrl = previewUrl;
        preview.src = previewUrl;
        preview.classList.remove('hidden');
        empty.classList.add('hidden');
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
            clearBulkVariantImagePreview(image);
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

    window.openViewProductModal = function (button) {
        var card = getProductCard(button);
        if (!card) return;

        var availability = (card.getAttribute('data-product-available') || '').toLowerCase() === 'true';
        var variants = Array.from(card.querySelectorAll('tbody tr')).map(function (row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 4) return '';

            return cells[1].textContent.trim() + ' — ' +
                cells[2].textContent.trim() + ' · ' +
                cells[3].textContent.trim();
        }).filter(Boolean);
        var fields = {
            name: getProductName(button),
            category: card.getAttribute('data-product-category') || '',
            description: card.getAttribute('data-product-description') || 'Not provided',
            variants: variants.length ? variants.join('\n') : 'No variants added'
        };

        Object.keys(fields).forEach(function (key) {
            var field = document.getElementById('viewProduct' + key.charAt(0).toUpperCase() + key.slice(1));
            if (field) field.textContent = fields[key];
        });

        var status = document.getElementById('viewProductAvailability');
        if (status) {
            status.textContent = availability ? 'Available' : 'Unavailable';
            status.className = availability
                ? 'inline-flex items-center rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700'
                : 'inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600';
        }
    };

    window.openEditProductModal = function (button, productId) {
        var card = getProductCard(button);
        if (!card) return;

        var id = findControl('hfEditProductID');
        var category = findControl('ddlEditProductCategory');
        var name = findControl('txtEditProductName');
        var description = findControl('txtEditProductDescription');
        var available = findControl('chkEditProductIsAvailable');

        if (id) id.value = productId;
        if (category) category.value = card.getAttribute('data-product-category-id') || '';
        if (name) name.value = getProductName(button);
        if (description) description.value = card.getAttribute('data-product-description') || '';
        if (available) {
            available.checked =
                (card.getAttribute('data-product-available') || '').toLowerCase() === 'true';
        }
    };

    window.openDeleteProductModal = function (button, productId) {
        var id = findControl('hfDeleteProductID');
        var name = document.getElementById('deleteProductName');

        if (id) id.value = productId;
        if (name) name.textContent = getProductName(button);
    };

    window.openViewVariantModal = function (
        button,
        sizeName,
        price,
        isAvailable,
        imageUrl
    ) {
        var card = button ? button.closest('[data-existing-size-keys]') : null;
        var productName = card && card.querySelector('[data-product-name]');
        var category = card ? card.getAttribute('data-product-category') || '' : '';
        var productStatus = card && (card.getAttribute('data-product-available') || '').toLowerCase() === 'true'
            ? 'Active'
            : 'Hidden';
        var imageWrap = document.getElementById('viewVariantImageWrap');
        var image = document.getElementById('viewVariantImage');
        var imageEmpty = document.getElementById('viewVariantNoImage');
        var fields = {
            product: productName ? productName.textContent.trim() : 'Selected product',
            category: category,
            description: card ? card.getAttribute('data-product-description') || 'Not provided' : 'Not provided',
            productStatus: productStatus,
            size: sizeName,
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
        var imageEmpty = document.getElementById('editVariantNoImage');
        var productLabel = getProductName(button);
        var productSizeKeys = getExistingSizeKeys(button);

        releaseEditVariantPreviewUrl();
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

        if (preview && image && imageEmpty) {
            preview.classList.toggle('hidden', !imageUrl);
            imageEmpty.classList.toggle('hidden', Boolean(imageUrl));
            image.src = imageUrl || '';
            image.dataset.originalSrc = imageUrl || '';
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
        if (event.target.matches('.bulk-variant-image')) {
            updateBulkVariantImagePreview(event.target);
            return;
        }

        if (event.target.matches('[id$="uploadEditVariantImage"]')) {
            var upload = event.target;
            var file = upload.files && upload.files[0];
            var preview = document.getElementById('editVariantImagePreview');
            var image = document.getElementById('editVariantCurrentImage');
            var imageEmpty = document.getElementById('editVariantNoImage');

            if (preview && image && imageEmpty) {
                releaseEditVariantPreviewUrl();

                if (file) {
                    editVariantPreviewUrl = window.URL.createObjectURL(file);
                    image.src = editVariantPreviewUrl;
                    preview.classList.remove('hidden');
                    imageEmpty.classList.add('hidden');
                } else {
                    var originalImageUrl = image.dataset.originalSrc || '';
                    image.src = originalImageUrl;
                    preview.classList.toggle('hidden', !originalImageUrl);
                    imageEmpty.classList.toggle('hidden', Boolean(originalImageUrl));
                }
            }

            return;
        }

        if (event.target.matches('.bulk-variant-size')) {
            refreshRows();
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        resetVariantRows();
        initializeProductFilters();
    });
})();
