(function () {
    'use strict';

    document.addEventListener('DOMContentLoaded', function () {
        var grid = document.getElementById('gridStaff');
        var search = document.getElementById('staffSearch');
        var role = document.getElementById('staffRoleFilter');
        var status = document.getElementById('staffStatusFilter');
        var count = document.getElementById('staffResultCount');
        var clear = document.getElementById('clearStaffFilters');
        var empty = document.getElementById('noStaffMatches');
        var reset = document.getElementById('resetStaffFilters');
        var table = document.getElementById('staffTableContainer');
        if (!grid || !search || !role || !status || !count || !clear || !empty || !reset || !table) return;

        function normalize(value) {
            return (value || '').toLocaleLowerCase().replace(/\s+/g, ' ').trim();
        }

        var accounts = Array.from(grid.querySelectorAll('[data-staff-account]')).map(function (name) {
            var row = name.closest('tr');
            var email = row.querySelector('[data-staff-email]');
            return {
                row: row,
                role: normalize(name.dataset.staffRole),
                active: normalize(name.dataset.staffActive),
                text: normalize(name.textContent + ' ' + (email ? email.textContent : ''))
            };
        });
        var storageKey = 'admin-staff-filters:' + window.location.pathname;

        // Retain filters through the view/edit postbacks without changing the
        // server-side account list or the GridView's row command arguments.
        try {
            var saved = JSON.parse(window.sessionStorage.getItem(storageKey) || 'null');
            if (saved) {
                search.value = typeof saved.search === 'string' ? saved.search.slice(0, 150) : '';
                role.value = typeof saved.role === 'string' ? saved.role : '';
                status.value = typeof saved.status === 'string' ? saved.status : '';
                if (role.selectedIndex < 0) role.value = '';
                if (status.selectedIndex < 0) status.value = '';
            }
        } catch (error) {
            // Filtering is still available if browser storage is blocked.
        }

        function applyFilters() {
            var terms = normalize(search.value).split(' ').filter(Boolean);
            var visibleCount = 0;
            accounts.forEach(function (account) {
                var matches = (!role.value || account.role === role.value) &&
                    (!status.value || account.active === status.value) &&
                    terms.every(function (term) { return account.text.indexOf(term) !== -1; });
                account.row.hidden = !matches;
                if (matches) visibleCount += 1;
            });

            count.textContent = 'Showing ' + visibleCount + ' of ' + accounts.length +
                (accounts.length === 1 ? ' staff account' : ' staff accounts');
            clear.hidden = !terms.length && !role.value && !status.value;
            var noMatches = visibleCount === 0 && accounts.length > 0;
            empty.hidden = !noMatches;
            table.hidden = noMatches;

            try {
                window.sessionStorage.setItem(storageKey, JSON.stringify({
                    search: search.value, role: role.value, status: status.value
                }));
            } catch (error) {
                // Browser storage is optional.
            }
        }

        function clearFilters() {
            search.value = '';
            role.value = '';
            status.value = '';
            applyFilters();
            search.focus();
        }

        search.addEventListener('input', applyFilters);
        search.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') event.preventDefault();
        });
        role.addEventListener('change', applyFilters);
        status.addEventListener('change', applyFilters);
        clear.addEventListener('click', clearFilters);
        reset.addEventListener('click', clearFilters);
        applyFilters();
    });
}());
