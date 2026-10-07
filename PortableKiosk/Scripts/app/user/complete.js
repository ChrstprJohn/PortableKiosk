(function () {
    "use strict";

    var countdown = document.getElementById("completeExpiry");
    if (!countdown) {
        return;
    }

    var remainingMilliseconds = Number(countdown.getAttribute("data-remaining-ms"));
    if (!Number.isFinite(remainingMilliseconds) || remainingMilliseconds < 0) {
        return;
    }

    var time = document.getElementById("completeExpiryTime");
    var label = document.getElementById("completeExpiryLabel");
    var hint = document.getElementById("completeExpiryHint");
    // Elapsed time keeps the countdown accurate after a suspended tab without
    // relying on the customer's device clock matching the server clock.
    var startedAt = performance.now();
    var interval;

    function updateCountdown() {
        var seconds = Math.max(0, Math.ceil(
            (remainingMilliseconds - (performance.now() - startedAt)) / 1000));
        var minutes = Math.floor(seconds / 60);
        time.textContent = (minutes < 10 ? "0" : "") + minutes + ":" +
            (seconds % 60 < 10 ? "0" : "") + (seconds % 60);

        if (seconds === 0) {
            label.textContent = "Order number expired";
            hint.textContent = "Start a new order to get a new number.";
            window.clearInterval(interval);
        }
        return seconds;
    }

    if (updateCountdown() > 0) {
        interval = window.setInterval(updateCountdown, 1000);
        document.addEventListener("visibilitychange", updateCountdown);
    }
}());
