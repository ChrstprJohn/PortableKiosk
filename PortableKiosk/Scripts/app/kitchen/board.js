(function () {
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

            var board = document.querySelector('.kitchen-columns');
            var lists = document.querySelectorAll('.kitchen-card-list');
            var key = 'kitchen-board-scroll';
            if (!board) return;
            try {
                var saved = JSON.parse(sessionStorage.getItem(key) || 'null');
                if (saved) {
                    board.scrollLeft = saved.left || 0;
                    for (var i = 0; i < lists.length; i++) lists[i].scrollTop = saved.tops[i] || 0;
                    sessionStorage.removeItem(key);
                }
            } catch (ignored) { }

            function saveScroll() {
                try {
                    var tops = [];
                    for (var i = 0; i < lists.length; i++) tops.push(lists[i].scrollTop);
                    sessionStorage.setItem(key, JSON.stringify({ left: board.scrollLeft, tops: tops }));
                } catch (ignored) { }
            }
            document.addEventListener('change', function (event) {
                if (event.target.classList.contains('kitchen-status')) saveScroll();
            }, true);
            window.addEventListener('pagehide', saveScroll);
        }());
