(function () {
            var settings = document.getElementById('kitchenSettings');
            var menu = document.getElementById('kitchenProfile');
            if (menu) {
                document.addEventListener('click', function (event) {
                    if (menu.open && !menu.contains(event.target)) menu.open = false;
                });
                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && menu.open) {
                        menu.open = false;
                        menu.querySelector('summary').focus();
                    }
                });
            }

            if (settings) {
                var period = document.getElementById('completedPeriod');
                var range = document.getElementById('completedDateRange');
                var from = document.getElementById('completedFrom');
                var to = document.getElementById('completedTo');
                var error = document.getElementById('completedFilterError');
                var applied = { period: period.value, from: from.value, to: to.value };

                function updateDateFields() {
                    var custom = period.value === 'custom';
                    range.hidden = !custom;
                    from.required = to.required = custom;
                    from.disabled = to.disabled = !custom;
                }

                function clearFilterError() {
                    error.hidden = true;
                    error.textContent = '';
                    from.setCustomValidity('');
                    to.setCustomValidity('');
                }

                updateDateFields();
                period.addEventListener('change', function () {
                    clearFilterError();
                    updateDateFields();
                });
                from.addEventListener('input', clearFilterError);
                to.addEventListener('input', clearFilterError);
                settings.addEventListener('toggle', function () {
                    if (settings.open) {
                        if (menu) menu.open = false;
                    } else {
                        period.value = applied.period;
                        from.value = applied.from;
                        to.value = applied.to;
                        clearFilterError();
                        updateDateFields();
                    }
                });
                if (menu) menu.addEventListener('toggle', function () {
                    if (menu.open) settings.open = false;
                });
                document.addEventListener('click', function (event) {
                    if (settings.open && !settings.contains(event.target)) settings.open = false;
                });
                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && settings.open) {
                        settings.open = false;
                        settings.querySelector('summary').focus();
                    }
                });
                document.getElementById('applyKitchenSettings').addEventListener('click', function () {
                    clearFilterError();
                    if (period.value === 'custom') {
                        if (!from.value || !to.value) {
                            error.textContent = 'Choose both a start and end date.';
                        } else if (!from.validity.valid || !to.validity.valid) {
                            error.textContent = 'Choose dates between January 1, 1753 and December 30, 9999.';
                        } else if (to.value < from.value) {
                            error.textContent = 'The end date must be on or after the start date.';
                        }
                        if (error.textContent) {
                            error.hidden = false;
                            (!from.value || !from.validity.valid ? from : to).focus();
                            return;
                        }
                    }
                    var url = new URL(window.location.href);
                    url.searchParams.set('completed', period.value);
                    url.searchParams.delete('from');
                    url.searchParams.delete('to');
                    if (period.value === 'custom') {
                        url.searchParams.set('from', from.value);
                        url.searchParams.set('to', to.value);
                    }
                    window.location.assign(url.href);
                });
            }

            // Keep the board current without interrupting settings or status changes.
            function refreshBoard() {
                var active = document.activeElement;
                var editing = active && /^(INPUT|SELECT|TEXTAREA)$/.test(active.tagName);
                if (document.hidden || editing || (settings && settings.open) || (menu && menu.open)) {
                    window.setTimeout(refreshBoard, 20000);
                    return;
                }
                window.location.reload();
            }
            window.setTimeout(refreshBoard, 20000);

            var board = document.querySelector('.kitchen-columns');
            var lists = document.querySelectorAll('.kitchen-card-list');
            var cards = document.querySelectorAll('.kitchen-collapsible-card');
            var key = 'kitchen-board-scroll';
            if (!board) return;
            try {
                var saved = JSON.parse(sessionStorage.getItem(key) || 'null');
                if (saved) {
                    var openOrders = saved.openOrders || [];
                    for (var c = 0; c < cards.length; c++) {
                        cards[c].open = openOrders.indexOf(cards[c].getAttribute('data-order-id')) !== -1;
                    }
                    board.scrollLeft = saved.left || 0;
                    var savedTops = saved.tops || [];
                    for (var i = 0; i < lists.length; i++) lists[i].scrollTop = savedTops[i] || 0;
                    sessionStorage.removeItem(key);
                }
            } catch (ignored) { }

            function saveScroll() {
                try {
                    var tops = [];
                    for (var i = 0; i < lists.length; i++) tops.push(lists[i].scrollTop);
                    var openOrders = [];
                    for (var c = 0; c < cards.length; c++) {
                        if (cards[c].open) openOrders.push(cards[c].getAttribute('data-order-id'));
                    }
                    sessionStorage.setItem(key, JSON.stringify({ left: board.scrollLeft, tops: tops, openOrders: openOrders }));
                } catch (ignored) { }
            }
            document.addEventListener('change', function (event) {
                if (event.target.classList.contains('kitchen-status')) saveScroll();
            }, true);
            window.addEventListener('pagehide', saveScroll);
        }());
