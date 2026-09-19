(function () {
    'use strict';

    /**
     * Pre-populates the Add Slot modal for a target Bundle.
     * @param {number|string} bundleId
     * @param {string} bundleName
     */
    window.openAddSlotModal = function (bundleId, bundleName) {
        var hfId = document.querySelector('[id$="hfModalSlotBundleID"]');
        var displaySpan = document.getElementById('modalDisplayBundleName');

        if (hfId) {
            hfId.value = bundleId;
        }

        if (displaySpan) {
            displaySpan.innerText = bundleName + ' (ID #' + bundleId + ')';
        }

        // Trigger slot type visibility check
        window.toggleSlotTypeFields();
    };

    /**
     * Pre-populates the Add Group Item modal for a target Option Group.
     * @param {number|string} groupId
     * @param {string} groupName
     */
    window.openAddGroupItemModal = function (groupId, groupName) {
        var hfId = document.querySelector('[id$="hfModalOptionGroupID"]');
        var displaySpan = document.getElementById('modalDisplayOptionGroupName');

        if (hfId) {
            hfId.value = groupId;
        }

        if (displaySpan) {
            displaySpan.innerText = groupName + ' (ID #' + groupId + ')';
        }
    };

    /**
     * Toggles between Fixed Variant and Option Group fields in the Slot Modal.
     */
    window.toggleSlotTypeFields = function () {
        var ddlType = document.querySelector('[id$="ddlModalSlotType"]');
        var fixedGroup = document.getElementById('slotFixedVariantGroup');
        var optionGroup = document.getElementById('slotOptionGroupGroup');

        if (!ddlType || !fixedGroup || !optionGroup) {
            return;
        }

        var isFixed = ddlType.value === 'FIXED';
        fixedGroup.style.display = isFixed ? 'block' : 'none';
        optionGroup.style.display = isFixed ? 'none' : 'block';
    };

    /**
     * Persists active tab across ASP.NET postbacks.
     */
    document.addEventListener('DOMContentLoaded', function () {
        var tabButtons = document.querySelectorAll('#bundleNavTabs button[data-bs-toggle="tab"]');
        var storedTab = localStorage.getItem('portable_kiosk_bundle_active_tab');

        if (storedTab) {
            var targetTabBtn = document.querySelector('#bundleNavTabs button[data-bs-target="' + storedTab + '"]');
            if (targetTabBtn && typeof bootstrap !== 'undefined' && bootstrap.Tab) {
                var tab = new bootstrap.Tab(targetTabBtn);
                tab.show();
            }
        }

        tabButtons.forEach(function (btn) {
            btn.addEventListener('shown.bs.tab', function (e) {
                var target = e.target.getAttribute('data-bs-target');
                if (target) {
                    localStorage.setItem('portable_kiosk_bundle_active_tab', target);
                }
            });
        });

        // Initialize slot type toggle listener
        var ddlType = document.querySelector('[id$="ddlModalSlotType"]');
        if (ddlType) {
            ddlType.addEventListener('change', window.toggleSlotTypeFields);
            window.toggleSlotTypeFields();
        }
    });
})();
