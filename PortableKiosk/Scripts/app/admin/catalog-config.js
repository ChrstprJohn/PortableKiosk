(function () {
    'use strict';

    function findControl(idSuffix) {
        return document.querySelector('[id$="' + idSuffix + '"]');
    }

    window.openEditCategoryModal = function (categoryId, categoryName, displayOrder, isAvailable) {
        var id = findControl('hfEditCategoryID');
        var name = findControl('txtEditCategoryName');
        var order = findControl('txtEditCategoryDisplayOrder');
        var available = findControl('chkEditCategoryIsAvailable');

        if (id) id.value = categoryId;
        if (name) name.value = categoryName;
        if (order) order.value = displayOrder;
        if (available) available.checked = isAvailable;
    };

    window.openDeleteCategoryModal = function (categoryId, categoryName) {
        var id = findControl('hfDeleteCategoryID');
        var name = document.getElementById('deleteCategoryName');

        if (id) id.value = categoryId;
        if (name) name.textContent = categoryName;
    };

    window.openEditSizeModal = function (sizeId, sizeName, displayOrder) {
        var id = findControl('hfEditSizeID');
        var name = findControl('txtEditSizeName');
        var order = findControl('txtEditSizeDisplayOrder');

        if (id) id.value = sizeId;
        if (name) name.value = sizeName;
        if (order) order.value = displayOrder;
    };

    window.openDeleteSizeModal = function (sizeId, sizeName) {
        var id = findControl('hfDeleteSizeID');
        var name = document.getElementById('deleteSizeName');

        if (id) id.value = sizeId;
        if (name) name.textContent = sizeName;
    };
})();
