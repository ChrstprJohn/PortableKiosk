/** Dialog behavior for Tailwind-styled Web Forms pages. */
window.AppModal = (function () {
    'use strict';
    var active = null;
    var previousFocus = null;

    function element(id) {
        return typeof id === 'string' ? document.getElementById(id.replace(/^#/, '')) : id;
    }
    function open(id) {
        var dialog = element(id);
        if (!dialog) return;
        if (active && active !== dialog) close(active);
        previousFocus = document.activeElement;
        active = dialog;
        dialog.classList.remove('hidden');
        dialog.classList.add('flex');
        dialog.setAttribute('role', 'dialog');
        dialog.setAttribute('aria-modal', 'true');
        dialog.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
        var focusTarget = dialog.querySelector('[autofocus]') ||
            dialog.querySelector('button, input, select, textarea, a[href]');
        (focusTarget || dialog).focus();
        dialog.dispatchEvent(new CustomEvent('modal:shown'));
    }
    function close(id) {
        var dialog = element(id);
        if (!dialog) return;
        dialog.classList.remove('flex');
        dialog.classList.add('hidden');
        dialog.setAttribute('aria-hidden', 'true');
        dialog.removeAttribute('aria-modal');
        if (active === dialog) {
            active = null;
            document.body.style.overflow = '';
            if (previousFocus && previousFocus.isConnected) previousFocus.focus();
            previousFocus = null;
        }
        dialog.dispatchEvent(new CustomEvent('modal:hidden'));
    }
    document.addEventListener('click', function (event) {
        var trigger = event.target.closest('[data-modal-toggle]');
        if (trigger) {
            event.preventDefault();
            open(trigger.getAttribute('data-modal-target'));
            return;
        }
        var dismiss = event.target.closest('[data-modal-dismiss]');
        if (dismiss) { close(dismiss.closest('[role="dialog"], [role="alertdialog"]')); return; }
        if (active && event.target === active && active.dataset.modalBackdrop !== 'static') close(active);
    });
    document.addEventListener('keydown', function (event) {
        if (!active) return;
        if (event.key === 'Escape' && active.dataset.modalKeyboard !== 'false') close(active);
        if (event.key !== 'Tab') return;
        var focusable = Array.from(active.querySelectorAll('button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])'));
        if (!focusable.length) return;
        var first = focusable[0], last = focusable[focusable.length - 1];
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    });

    var variants = {
        primary: {header: 'bg-blue-700 text-white', button: 'border-blue-700 bg-blue-700 text-white hover:bg-blue-800'},
        danger: {header: 'bg-red-700 text-white', button: 'border-red-700 bg-red-700 text-white hover:bg-red-800'},
        success: {header: 'bg-emerald-700 text-white', button: 'border-emerald-700 bg-emerald-700 text-white hover:bg-emerald-800'},
        warning: {header: 'bg-amber-300 text-slate-900', button: 'border-amber-500 bg-amber-400 text-slate-900 hover:bg-amber-500'},
        dark: {header: 'bg-slate-900 text-white', button: 'border-slate-900 bg-slate-900 text-white hover:bg-slate-800'},
        light: {header: 'bg-slate-100 text-slate-900', button: 'border-slate-300 bg-white text-slate-900 hover:bg-slate-100'}
    };
    function escapeHtml(value) {
        return String(value == null ? '' : value).replace(/[&<>"']/g, function (char) {
            return {'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;'}[char];
        }).replace(/'/g, '&#39;');
    }
    function create(options, isConfirm) {
        var id = 'app-dynamic-' + Date.now() + '-' + Math.random().toString(36).slice(2);
        var style = variants[options.variant] || variants.primary;
        var button = 'inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors';
        var cancel = '<button type="button" class="' + button + ' border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true" data-action="cancel">' + escapeHtml(options.cancelText) + '</button>';
        var html = '<div id="' + id + '" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" tabindex="-1" aria-hidden="true" data-modal-backdrop="static">' +
            '<div class="w-full max-w-lg"><div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">' +
            '<div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 ' + style.header + '">' +
            '<h2 class="text-lg font-semibold">' + escapeHtml(options.title) + '</h2>' +
            '<button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10" data-modal-dismiss="true" aria-label="Close">&times;</button></div>' +
            '<div class="overflow-y-auto p-5">' + options.message + '</div>' +
            '<div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 bg-slate-50 px-5 py-4">' + (isConfirm ? cancel : '') +
            '<button type="button" class="' + button + ' ' + style.button + '" data-modal-dismiss="true" data-action="confirm">' + escapeHtml(isConfirm ? options.confirmText : options.buttonText) + '</button>' +
            '</div></div></div></div>';
        document.body.insertAdjacentHTML('beforeend', html);
        var dialog = document.getElementById(id);
        dialog.querySelector('[data-action="confirm"]').addEventListener('click', function () {
            if (typeof options.onConfirm === 'function') options.onConfirm();
        });
        if (isConfirm) dialog.querySelector('[data-action="cancel"]').addEventListener('click', function () {
            if (typeof options.onCancel === 'function') options.onCancel();
        });
        dialog.addEventListener('modal:hidden', function () { dialog.remove(); }, {once:true});
        open(dialog);
    }
    return {
        open: open, show: open, close: close, hide: close,
        getActive: function () { return active; },
        alert: function (options) { create(Object.assign({title:'Notice', message:'', variant:'primary', buttonText:'OK'}, options), false); },
        confirm: function (options) { create(Object.assign({title:'Confirm Action', message:'Are you sure you want to proceed?', variant:'danger', confirmText:'Confirm', cancelText:'Cancel'}, options), true); }
    };
})();
