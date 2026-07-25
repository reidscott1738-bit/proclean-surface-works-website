(function () {
  "use strict";

  // ---- Nav: shadow on scroll ----
  var nav = document.getElementById('nav');
  if (nav) {
    var scrolled = null;
    var onScroll = function () {
      var y = window.scrollY > 30;
      if (y !== scrolled) { scrolled = y; nav.classList.toggle('scrolled', y); }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ---- Mobile menu toggle ----
  var toggle = document.getElementById('navToggle');
  var links = document.getElementById('navLinks');
  if (toggle && links) {
    toggle.addEventListener('click', function () {
      var open = links.classList.toggle('open');
      toggle.classList.toggle('open', open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    links.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        links.classList.remove('open');
        toggle.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // ---- Before / After sliders ----
  document.querySelectorAll('.ba-slider').forEach(function (s) {
    var handle = s.querySelector('.ba-handle');
    var pos = 50, dragging = false;
    function set(v) {
      pos = Math.max(0, Math.min(100, v));
      s.style.setProperty('--pos', pos + '%');
      if (handle) handle.setAttribute('aria-valuenow', Math.round(pos));
    }
    function fromEvent(e) {
      var r = s.getBoundingClientRect();
      var cx = (e.touches && e.touches[0]) ? e.touches[0].clientX : e.clientX;
      set((cx - r.left) / r.width * 100);
    }
    s.addEventListener('pointerdown', function (e) {
      dragging = true;
      if (s.setPointerCapture) { try { s.setPointerCapture(e.pointerId); } catch (x) {} }
      fromEvent(e);
    });
    s.addEventListener('pointermove', function (e) { if (dragging) fromEvent(e); });
    window.addEventListener('pointerup', function () { dragging = false; });
    if (handle) {
      handle.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowLeft') { set(pos - 4); e.preventDefault(); }
        if (e.key === 'ArrowRight') { set(pos + 4); e.preventDefault(); }
      });
    }
    set(50);
  });

  // ---- Subtle reveal on scroll (safe: only hides once JS confirms support) ----
  if ('IntersectionObserver' in window && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    var els = document.querySelectorAll('.reveal');
    if (els.length) {
      document.body.classList.add('reveal-on');
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
        });
      }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
      els.forEach(function (el) { io.observe(el); });
    }
  }
})();
