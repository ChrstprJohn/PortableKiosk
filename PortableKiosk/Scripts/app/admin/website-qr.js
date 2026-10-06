(function () {
    "use strict";
    var image = document.getElementById("websiteQrImage");
    var link = document.getElementById("lnkWebsite");
    if (!image || !link) return;

    try {
        var url = link.getAttribute("href");
        var qr = qrcodegen.QrCode.encodeText(url, qrcodegen.QrCode.Ecc.MEDIUM);
        var border = 4; // Quiet zone required for reliable scanning, including on paper.
        var size = qr.size + border * 2;
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute("viewBox", "0 0 " + size + " " + size);
        svg.setAttribute("shape-rendering", "crispEdges");
        svg.setAttribute("aria-hidden", "true");
        var background = document.createElementNS(svg.namespaceURI, "rect");
        background.setAttribute("width", size);
        background.setAttribute("height", size);
        background.setAttribute("fill", "#ffffff");
        svg.appendChild(background);

        var path = document.createElementNS(svg.namespaceURI, "path");
        var modules = [];
        for (var y = 0; y < qr.size; y++) {
            for (var x = 0; x < qr.size; x++) {
                if (qr.getModule(x, y)) {
                    modules.push("M" + (x + border) + "," + (y + border) + "h1v1h-1z");
                }
            }
        }
        path.setAttribute("d", modules.join(" "));
        path.setAttribute("fill", "#000000");
        svg.appendChild(path);
        image.appendChild(svg);
        document.getElementById("qrActions").hidden = false;
        var host = new URL(url).hostname.toLowerCase();
        document.getElementById("qrLocalNotice").hidden = !(
            host === "localhost" || host.endsWith(".localhost") ||
            host === "127.0.0.1" || host === "[::1]");
        document.getElementById("btnPrintQr").addEventListener("click", function () {
            window.print();
        });
    } catch (error) {
        document.getElementById("websiteQrError").hidden = false;
    }
}());
