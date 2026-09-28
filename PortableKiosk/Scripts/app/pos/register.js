(function () {
    "use strict";

    function byId(id) {
        return document.getElementById(id);
    }

    var categoryField = byId("hdnCategory");
    var orderNumberField = byId("txtOrderSearch");
    var tenderedField = byId("txtTendered");
    var changePreview = byId("posChangePreview");
    var tenderedHint = byId("posTenderedHint");
    var errorMessage = byId("lblError");
    var profileMenu = document.querySelector("[data-pos-profile-menu]");
    var profileName = byId("posProfileLastName");

    function selectFilter(selector, activeValue, attribute) {
        document.querySelectorAll(selector).forEach(function (button) {
            var selected = button.getAttribute(attribute) === activeValue;
            button.setAttribute("aria-pressed", selected ? "true" : "false");
            button.classList.toggle("bg-slate-900", selected);
            button.classList.toggle("text-white", selected);
            button.classList.toggle("bg-slate-100", !selected);
            button.classList.toggle("text-slate-700", !selected);
        });
    }

    function applyFilters() {
        if (!categoryField) return;

        var category = categoryField.value;
        var visible = 0;
        var totalTiles = 0;

        document.querySelectorAll("[data-pos-add-product]").forEach(function (tile) {
            totalTiles += 1;
            var matches = tile.dataset.posCategoryId === category;
            tile.style.display = matches ? "" : "none";
            if (matches) visible += 1;
        });

        document.querySelectorAll("[data-pos-size-row]").forEach(function (row) {
            var hasProducts = row.querySelector(
                '[data-pos-add-product]:not([style*="display: none"])');
            row.style.display = hasProducts ? "" : "none";
        });

        selectFilter("[data-pos-category]", category, "data-pos-category");

        var empty = byId("posFilterEmpty");
        if (empty) empty.style.display = visible || !totalTiles ? "none" : "block";
    }

    function formatCash(amount) {
        return "₱" + amount.toLocaleString("en-PH", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function updateChange() {
        if (!tenderedField || !changePreview) return;
        var total = Number(changePreview.dataset.total || "0");
        var received = Number(tenderedField.value.replace(/,/g, ""));
        var isValid = tenderedField.value.trim() !== "" &&
            Number.isFinite(received) && received >= 0;

        changePreview.textContent = formatCash(
            isValid && received >= total ? received - total : 0);

        if (tenderedHint) {
            tenderedHint.textContent = !isValid
                ? "Enter the amount handed to you."
                : received < total
                    ? formatCash(total - received) + " still due."
                    : "Ready to complete payment.";
        }
    }

    function pressCash(key) {
        if (!tenderedField) return;
        var value = tenderedField.value;

        if (key === "clear") {
            value = "";
        } else if (key === ".") {
            if (value.indexOf(".") === -1) value = (value || "0") + ".";
        } else if (/^[0-9]$/.test(key)) {
            var decimalPart = value.split(".")[1];
            if (!decimalPart || decimalPart.length < 2) {
                value = value === "0" ? key : value + key;
            }
        }

        if (value.length <= 11) {
            tenderedField.value = value;
            updateChange();
            tenderedField.focus();
        }
    }

    function setQuickCash(amount) {
        if (!tenderedField) return;
        if (amount === "exact") {
            var total = changePreview ? Number(changePreview.dataset.total || "0") : 0;
            tenderedField.value = total.toFixed(2);
        } else {
            tenderedField.value = amount;
        }
        updateChange();
    }

    function pressOrderNumber(key) {
        if (!orderNumberField) return;
        var value = orderNumberField.value.replace(/[^0-9]/g, "");

        if (key === "clear") {
            value = "";
        } else if (key === "back") {
            value = value.slice(0, -1);
        } else if (/^[0-9]$/.test(key) && value.length < 20) {
            value += key;
        }

        orderNumberField.value = value ? "#" + value : "";
    }

    function formatOrderNumber() {
        if (!orderNumberField) return;
        var value = orderNumberField.value.replace(/[^0-9]/g, "").slice(0, 20);
        orderNumberField.value = value ? "#" + value : "";
        if (typeof orderNumberField.setSelectionRange === "function") {
            var end = orderNumberField.value.length;
            orderNumberField.setSelectionRange(end, end);
        }
    }

    function clearError() {
        if (!errorMessage) return;

        errorMessage.textContent = "";
        errorMessage.hidden = true;
        errorMessage.style.opacity = "";
    }

    function dismissError() {
        if (!errorMessage || !errorMessage.textContent.trim()) return;

        window.setTimeout(function () {
            errorMessage.style.opacity = "0";
        }, 4800);
        window.setTimeout(function () {
            errorMessage.hidden = true;
        }, 5000);
    }

    function bindProfileLastName() {
        if (!profileName) return;

        var lastName = (profileName.textContent || "").trim();
        if (!lastName) {
            lastName = (profileName.getAttribute("data-last-name") || "").trim();
        }
        if (!lastName) {
            var displayName = (profileName.getAttribute("data-display-name") || "").trim();
            var nameParts = displayName ? displayName.split(/\s+/) : [];
            lastName = nameParts.length
                ? nameParts[nameParts.length - 1]
                : "Profile";
        }

        profileName.textContent = lastName;
    }

    document.addEventListener("click", function (event) {
        if (profileMenu && profileMenu.open && !profileMenu.contains(event.target)) {
            profileMenu.open = false;
        }

        if (event.target.closest("button, a, input[type='submit']")) {
            clearError();
        }

        var button = event.target.closest("button");
        if (!button) return;

        if (button.hasAttribute("data-pos-category")) {
            categoryField.value = button.dataset.posCategory;
            applyFilters();
        } else if (button.hasAttribute("data-pos-cash-quick")) {
            setQuickCash(button.dataset.posCashQuick);
        } else if (button.hasAttribute("data-pos-cash-key")) {
            pressCash(button.dataset.posCashKey);
        } else if (button.hasAttribute("data-pos-order-key")) {
            pressOrderNumber(button.dataset.posOrderKey);
        } else if (button.hasAttribute("data-pos-add-product")) {
            byId("hdnProductVariantID").value = button.dataset.posAddProduct;
            byId("btnAddProduct").click();
        } else if (button.hasAttribute("data-pos-line-action")) {
            byId("hdnProductVariantID").value = button.dataset.posVariant;
            byId("hdnLineAction").value = button.dataset.posLineAction;
            byId("btnLineAction").click();
        }
    });

    window.addEventListener("pagehide", clearError);
    window.addEventListener("pageshow", function (event) {
        if (event.persisted) clearError();
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && profileMenu && profileMenu.open) {
            profileMenu.open = false;
            var trigger = profileMenu.querySelector("summary");
            if (trigger) trigger.focus();
        }
    });

    if (tenderedField) {
        tenderedField.addEventListener("input", updateChange);
        updateChange();
    }

    if (orderNumberField) {
        orderNumberField.addEventListener("input", formatOrderNumber);
        formatOrderNumber();
    }

    if (categoryField) applyFilters();
    dismissError();
    bindProfileLastName();
}());
