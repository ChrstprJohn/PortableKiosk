/**
 * AppModal - Reusable Popup & Modal Utility
 * Allows opening/closing existing modals or creating dynamic alert/confirm dialogs from JS.
 */
window.AppModal = (function () {
    'use strict';

    function open(modalId) {
        var el = document.getElementById(modalId);
        if (!el) return;
        var modal = bootstrap.Modal.getOrCreateInstance(el);
        if (modal) modal.show();
    }

    function close(modalId) {
        var el = document.getElementById(modalId);
        if (!el) return;
        var modal = bootstrap.Modal.getInstance(el);
        if (modal) modal.hide();
    }

    /**
     * Shows a dynamic popup alert dialog
     * @param {Object} options - { title, message, variant ('primary'|'danger'|'success'|'warning'|'dark'), buttonText, onConfirm }
     */
    function alert(options) {
        options = Object.assign({
            title: 'Notice',
            message: '',
            variant: 'primary',
            buttonText: 'OK',
            onConfirm: null
        }, options);

        var dialogId = 'app-dynamic-alert-' + Date.now();
        var headerBg = 'bg-' + options.variant;
        var headerText = (options.variant === 'light' || options.variant === 'warning') ? 'text-dark' : 'text-white';
        var closeBtnClass = (options.variant === 'light' || options.variant === 'warning') ? '' : 'btn-close-white';

        var html = `
        <div class="modal fade" id="${dialogId}" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow border-0">
                    <div class="modal-header ${headerBg} ${headerText}">
                        <h5 class="modal-title">${escapeHtml(options.title)}</h5>
                        <button type="button" class="btn-close ${closeBtnClass}" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body py-4">
                        ${options.message}
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-${options.variant}" data-bs-dismiss="modal" id="${dialogId}-btn-ok">${escapeHtml(options.buttonText)}</button>
                    </div>
                </div>
            </div>
        </div>`;

        document.body.insertAdjacentHTML('beforeend', html);
        var modalEl = document.getElementById(dialogId);
        var modal = new bootstrap.Modal(modalEl);

        var okBtn = document.getElementById(dialogId + '-btn-ok');
        if (okBtn) {
            okBtn.addEventListener('click', function () {
                if (typeof options.onConfirm === 'function') {
                    options.onConfirm();
                }
            });
        }

        modalEl.addEventListener('hidden.bs.modal', function () {
            modalEl.remove();
        });

        modal.show();
    }

    /**
     * Shows a dynamic confirmation popup dialog
     * @param {Object} options - { title, message, variant, confirmText, cancelText, onConfirm, onCancel }
     */
    function confirm(options) {
        options = Object.assign({
            title: 'Confirm Action',
            message: 'Are you sure you want to proceed?',
            variant: 'danger',
            confirmText: 'Confirm',
            cancelText: 'Cancel',
            onConfirm: null,
            onCancel: null
        }, options);

        var dialogId = 'app-dynamic-confirm-' + Date.now();
        var headerBg = 'bg-' + options.variant;
        var headerText = (options.variant === 'light' || options.variant === 'warning') ? 'text-dark' : 'text-white';
        var closeBtnClass = (options.variant === 'light' || options.variant === 'warning') ? '' : 'btn-close-white';

        var html = `
        <div class="modal fade" id="${dialogId}" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow border-0">
                    <div class="modal-header ${headerBg} ${headerText}">
                        <h5 class="modal-title">${escapeHtml(options.title)}</h5>
                        <button type="button" class="btn-close ${closeBtnClass}" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body py-4">
                        ${options.message}
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="${dialogId}-btn-cancel">${escapeHtml(options.cancelText)}</button>
                        <button type="button" class="btn btn-${options.variant}" data-bs-dismiss="modal" id="${dialogId}-btn-confirm">${escapeHtml(options.confirmText)}</button>
                    </div>
                </div>
            </div>
        </div>`;

        document.body.insertAdjacentHTML('beforeend', html);
        var modalEl = document.getElementById(dialogId);
        var modal = new bootstrap.Modal(modalEl);

        var confirmBtn = document.getElementById(dialogId + '-btn-confirm');
        var cancelBtn = document.getElementById(dialogId + '-btn-cancel');

        if (confirmBtn) {
            confirmBtn.addEventListener('click', function () {
                if (typeof options.onConfirm === 'function') {
                    options.onConfirm();
                }
            });
        }

        if (cancelBtn) {
            cancelBtn.addEventListener('click', function () {
                if (typeof options.onCancel === 'function') {
                    options.onCancel();
                }
            });
        }

        modalEl.addEventListener('hidden.bs.modal', function () {
            modalEl.remove();
        });

        modal.show();
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    return {
        open: open,
        close: close,
        show: open,
        hide: close,
        alert: alert,
        confirm: confirm
    };
})();
