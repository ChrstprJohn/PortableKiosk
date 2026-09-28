window.AdminAlert = (function (window, document) {
    'use strict';

    var queue = [];
    var isOpen = false;
    var suspendedDialog = null;
    var dialog = null;
    var titleNode = null;
    var messageNode = null;
    var iconNode = null;
    var confirmButton = null;

    var variants = {
        success: {
            title: 'Success',
            iconClass: 'bg-emerald-50 text-emerald-700',
            buttonClass: 'border-emerald-700 bg-emerald-700 text-white hover:bg-emerald-800',
            icon: '<path d="m5 12 4 4L19 6" /><circle cx="12" cy="12" r="9" />'
        },
        error: {
            title: 'Error',
            iconClass: 'bg-red-50 text-red-700',
            buttonClass: 'border-red-700 bg-red-700 text-white hover:bg-red-800',
            icon: '<path d="m15 9-6 6m0-6 6 6" /><circle cx="12" cy="12" r="9" />'
        },
        info: {
            title: 'Information',
            iconClass: 'bg-blue-50 text-blue-700',
            buttonClass: 'border-blue-700 bg-blue-700 text-white hover:bg-blue-800',
            icon: '<circle cx="12" cy="12" r="9" /><path d="M12 11v5m0-8h.01" />'
        },
        warning: {
            title: 'Warning',
            iconClass: 'bg-amber-50 text-amber-700',
            buttonClass: 'border-amber-600 bg-amber-500 text-slate-950 hover:bg-amber-400',
            icon: '<path d="m10.3 3.9-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.7-3.1l-8-14a2 2 0 0 0-3.4 0Z" /><path d="M12 9v4m0 4h.01" />'
        }
    };

    function normalizeType(type) {
        type = String(type || 'info').toLowerCase();
        if (type === 'danger') return 'error';
        if (type === 'information' || type === 'primary') return 'info';
        return variants[type] ? type : 'info';
    }

    function getElements() {
        if (dialog) return true;
        dialog = document.getElementById('adminAlertModal');
        if (!dialog) return false;

        titleNode = document.getElementById('adminAlertTitle');
        messageNode = document.getElementById('adminAlertMessage');
        iconNode = document.getElementById('adminAlertIcon');
        confirmButton = document.getElementById('adminAlertConfirm');

        dialog.addEventListener('modal:hidden', onDialogHidden);
        return !!(titleNode && messageNode && iconNode && confirmButton);
    }

    function presentNext() {
        if (isOpen || !queue.length || !getElements() || !window.AppModal) return;

        var item = queue.shift();
        var variant = variants[item.type];
        titleNode.textContent = item.title || variant.title;
        messageNode.textContent = item.message;
        iconNode.className = 'inline-flex size-10 shrink-0 items-center justify-center rounded-full ' + variant.iconClass;
        iconNode.innerHTML = '<svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + variant.icon + '</svg>';
        confirmButton.className = 'inline-flex min-h-9 items-center justify-center rounded-md border px-3 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400 ' + variant.buttonClass;

        isOpen = true;
        window.AppModal.open(dialog);
        dialog.setAttribute('role', 'alertdialog');
    }

    function onDialogHidden() {
        isOpen = false;

        if (queue.length) {
            presentNext();
            return;
        }

        var previousDialog = suspendedDialog;
        suspendedDialog = null;
        if (previousDialog && document.documentElement.contains(previousDialog) && previousDialog.classList.contains('hidden')) {
            window.AppModal.open(previousDialog);
        }
    }

    function show(type, message, title) {
        if (type && typeof type === 'object') {
            title = type.title;
            message = type.message;
            type = type.type;
        }

        type = normalizeType(type);
        if (!isOpen && !queue.length && window.AppModal) {
            var activeDialog = window.AppModal.getActive();
            suspendedDialog = activeDialog && activeDialog !== dialog ? activeDialog : null;
        }

        queue.push({
            type: type,
            title: title == null ? '' : String(title),
            message: message == null ? '' : String(message)
        });
        presentNext();
    }

    return {
        show: show,
        success: function (message, title) { show('success', message, title); },
        error: function (message, title) { show('error', message, title); },
        info: function (message, title) { show('info', message, title); },
        information: function (message, title) { show('info', message, title); },
        warning: function (message, title) { show('warning', message, title); }
    };
})(window, document);
