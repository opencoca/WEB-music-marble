// Screenshot automation — injected into a temporary copy of index.html by
// `make screenshots`, never shipped to users. With #play in the URL it starts
// the simulation and holds a gravity well so the marble is orbiting with
// contour rings visible when the headless browser's virtual-time budget expires.
(() => {
    if (location.hash.slice(1) !== 'play') return;
    setTimeout(() => {
        document.getElementById('start-btn').click();
        setTimeout(() => {
            const c = document.getElementById('canvas');
            const x = Math.round(window.innerWidth * 0.58);
            const y = Math.round(window.innerHeight * 0.40);
            c.dispatchEvent(new MouseEvent('mousedown', { clientX: x, clientY: y, bubbles: true }));
            // A touch of tilt so the orbit has visible momentum on desktop
            window.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight' }));
        }, 400);
    }, 300);
})();
