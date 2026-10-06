(function () {
    'use strict';
    var modal = document.getElementById('analyticsDetailModal');
    if (!modal) return;
    var title = document.getElementById('analyticsDetailTitle');
    var period = document.getElementById('analyticsDetailPeriod');
    var description = document.getElementById('analyticsDetailDescription');
    var summary = document.getElementById('analyticsDetailSummary');
    var status = document.getElementById('analyticsDetailStatus');
    var content = document.getElementById('analyticsDetailContent');
    var table = document.getElementById('analyticsDetailTable');
    var search = document.getElementById('analyticsDetailSearch');
    var count = document.getElementById('analyticsDetailCount');
    var previous = document.getElementById('analyticsDetailPrevious');
    var next = document.getElementById('analyticsDetailNext');
    var retry = document.getElementById('analyticsDetailRetry');
    var exportButton = document.getElementById('analyticsDetailExport');
    var backButton = document.getElementById('analyticsDetailBack');
    var history = [];
    var data = null, selection = null, controller = null, page = 0, pageSize = 25, requestVersion = 0;
    var money = new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' });
    var number = new Intl.NumberFormat('en-PH');
    var percent = new Intl.NumberFormat('en-PH', {style:'percent', maximumFractionDigits:1, minimumFractionDigits:1});
    var inertSiblings = [];

    modal.addEventListener('modal:shown', function () {
        // Isolate this dialog from the navigation and report for keyboard and assistive technology.
        for (var ancestor = modal; ancestor.parentElement; ancestor = ancestor.parentElement) {
            Array.from(ancestor.parentElement.children).forEach(function (sibling) {
                if (sibling !== ancestor && !sibling.inert) { sibling.inert = true; inertSiblings.push(sibling); }
            });
        }
    });
    modal.addEventListener('modal:hidden', function () {
        inertSiblings.forEach(function (sibling) { sibling.inert = false; });
        inertSiblings = [];
        // The shared modal restores focus before emitting modal:hidden; the trigger is inert until now.
        if (selection && selection.trigger && selection.trigger.isConnected) selection.trigger.focus();
    });
    modal.addEventListener('keydown', function (event) {
        if (event.key !== 'Tab') return;
        // The Back button and content are hidden while loading; exclude them from the focus loop.
        event.stopPropagation();
        var controls = Array.from(modal.querySelectorAll('button:not([disabled]), input:not([disabled]), [tabindex="0"]'))
            .filter(function (control) { return control.getClientRects().length > 0; });
        var first = controls[0], last = controls[controls.length - 1];
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    });

    function url(exporting) {
        var result = new URL(modal.dataset.endpoint, window.location.href);
        result.searchParams.set('period', modal.dataset.period);
        result.searchParams.set('kind', selection.kind);
        if (selection.key) result.searchParams.set('key', selection.key);
        if (exporting) result.searchParams.set('export', 'xlsx');
        return result;
    }
    function cell(tag, value, parent, format) {
        var element = document.createElement(tag);
        element.textContent = tag !== 'th' && format === 'money' ? money.format(value) : tag !== 'th' && format === 'count' ? number.format(value) :
            tag !== 'th' && format === 'percent' ? percent.format(value) : String(value == null ? '' : value);
        if (format === 'money' || format === 'count' || format === 'percent') element.className = 'numeric';
        if (tag === 'th') element.scope = 'col';
        parent.appendChild(element);
        return element;
    }
    function render() {
        var term = search.value.trim().toLocaleLowerCase();
        var rows = data.Rows.filter(function (row) {
            return !term || row.some(function (value) { return String(value).toLocaleLowerCase().includes(term); });
        });
        var start = page * pageSize;
        table.replaceChildren();
        table.className = 'analytics-detail-table ' + (data.RowTargets.length ? 'breakdown' : 'source-records');
        var caption = document.createElement('caption');
        caption.textContent = data.Title + (data.RowTargets.length ? ' · Breakdown' : ' · Source records');
        table.appendChild(caption);
        var head = table.createTHead().insertRow();
        data.Columns.forEach(function (label, i) { cell('th', label, head, data.Formats[i] === 'text' ? null : data.Formats[i]); });
        var body = table.createTBody();
        rows.slice(start, start + pageSize).forEach(function (row) {
            var tr = body.insertRow();
            var target = data.RowTargets[data.Rows.indexOf(row)];
            row.forEach(function (value, i) {
                var td = cell('td', value, tr, data.Formats[i]);
                if (i === 0 && target) {
                    td.textContent = '';
                    var button = document.createElement('button');
                    button.type = 'button';
                    button.className = 'analytics-drill-link';
                    button.textContent = String(value);
                    button.dataset.analyticsKind = target.Kind;
                    if (target.Key) button.dataset.analyticsKey = target.Key;
                    button.dataset.analyticsTitle = String(value);
                    button.setAttribute('aria-haspopup', 'dialog');
                    button.setAttribute('aria-label', String(value) + ': view underlying records');
                    td.appendChild(button);
                    tr.dataset.analyticsKind = target.Kind;
                    if (target.Key) tr.dataset.analyticsKey = target.Key;
                    tr.dataset.analyticsTitle = String(value);
                }
            });
        });
        if (!rows.length) {
            var empty = cell('td', term ? 'No records match your search.' : 'No matching source records in this period.', body.insertRow());
            empty.colSpan = data.Columns.length;
        }
        var unit = data.RowTargets.length ? ' rows' : ' records';
        count.textContent = rows.length ? (start + 1) + '–' + Math.min(start + pageSize, rows.length) + ' of ' + number.format(rows.length) + unit : '0' + unit;
        if (term) count.textContent += ' · ' + number.format(data.Rows.length) + ' total';
        previous.disabled = page === 0;
        next.disabled = start + pageSize >= rows.length;
    }
    async function load() {
        var version = ++requestVersion;
        if (controller) controller.abort();
        controller = new AbortController();
        data = null;
        search.value = '';
        page = 0;
        content.hidden = true;
        retry.hidden = true;
        exportButton.disabled = true;
        exportButton.textContent = 'Export this data';
        backButton.hidden = history.length === 0;
        status.hidden = false;
        status.textContent = 'Loading source records…';
        description.textContent = '';
        summary.textContent = '';
        modal.setAttribute('aria-busy', 'true');
        try {
            var response = await fetch(url(false), { signal: controller.signal, credentials: 'same-origin' });
            var result = await response.json();
            if (!response.ok) throw new Error(result.Error || 'These records could not be loaded. Please try again.');
            if (version !== requestVersion) return;
            data = result;
            selection.title = data.Title;
            title.textContent = data.Title;
            period.textContent = data.Period;
            description.textContent = data.Description;
            summary.textContent = data.Summary;
            status.hidden = true;
            content.hidden = false;
            exportButton.disabled = false;
            exportButton.textContent = data.RowTargets.length ? 'Export breakdown' : 'Export all records';
            render();
            if (history.length) title.focus();
        } catch (error) {
            if (version !== requestVersion || error.name === 'AbortError') return;
            status.textContent = error.message || 'These records could not be loaded. Please try again.';
            retry.hidden = false;
        } finally {
            if (version === requestVersion) modal.setAttribute('aria-busy', 'false');
        }
    }
    function open(trigger) {
        var originalTrigger = trigger;
        if (trigger.closest('#analyticsDetailModal') && selection) {
            history.push(selection);
            originalTrigger = selection.trigger;
        } else history = [];
        selection = { kind: trigger.dataset.analyticsKind || trigger.dataset.analyticsSurface, key: trigger.dataset.analyticsKey || '', trigger: originalTrigger,
            title: trigger.dataset.analyticsTitle || 'Analytics details' };
        title.textContent = trigger.dataset.analyticsTitle || 'Analytics details';
        period.textContent = modal.dataset.periodLabel;
        if (window.AppModal.getActive() !== modal) {
            window.AppModal.open(modal);
            modal.querySelector('[aria-label="Close analytics details"]').focus();
        }
        load();
    }
    document.addEventListener('click', function (event) {
        var trigger = event.target.closest('[data-analytics-kind], [data-analytics-surface]');
        if (!trigger) return;
        event.preventDefault();
        open(trigger);
    });
    document.addEventListener('keydown', function (event) {
        var trigger = event.target.closest('[data-analytics-kind][role="button"]');
        if (trigger && (event.key === 'Enter' || event.key === ' ')) { event.preventDefault(); open(trigger); }
    });
    modal.addEventListener('modal:hidden', function () { ++requestVersion; if (controller) controller.abort(); });
    search.addEventListener('input', function () { page = 0; render(); });
    previous.addEventListener('click', function () { page--; render(); });
    next.addEventListener('click', function () { page++; render(); });
    retry.addEventListener('click', load);
    backButton.addEventListener('click', function () {
        if (!history.length) return;
        selection = history.pop();
        title.textContent = selection.title;
        load();
        title.focus();
    });
    exportButton.addEventListener('click', async function () {
        var version = requestVersion;
        exportButton.disabled = true;
        exportButton.textContent = 'Preparing Excel…';
        try {
            var response = await fetch(url(true), { credentials: 'same-origin' });
            if (!response.ok) { var error = await response.json(); throw new Error(error.Error); }
            var blob = await response.blob();
            var downloadUrl = URL.createObjectURL(blob);
            var link = document.createElement('a');
            link.href = downloadUrl;
            var disposition = response.headers.get('Content-Disposition') || '';
            var filename = /filename="([^"]+)"/.exec(disposition);
            link.download = filename ? filename[1] : 'analytics-details.xlsx';
            document.body.appendChild(link);
            link.click();
            link.remove();
            setTimeout(function () { URL.revokeObjectURL(downloadUrl); }, 1000);
        } catch (error) {
            if (version === requestVersion) { status.hidden = false; status.textContent = error.message || 'Export failed. Please try again.'; }
        } finally {
            if (version === requestVersion) {
                exportButton.textContent = data && data.RowTargets.length ? 'Export breakdown' : 'Export all records';
                exportButton.disabled = !data;
            }
        }
    });
})();
