(function () {
  "use strict";
  var WEB3FORMS_KEY = '2aac74f7-51f5-4885-bf0e-ec74252de553';

  // ---- Header shadow (writes only on state change) ----
  var header = document.querySelector('.site-header');
  var mBar = document.getElementById('mBar');
  var quote = document.getElementById('quote');
  if (header) {
    var scrolled = null;
    var onScroll = function () {
      var s = window.scrollY > 8;
      if (s !== scrolled) { scrolled = s; header.classList.toggle('scrolled', s); }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ---- Hide the mobile action bar while the quote form or footer is on screen ----
  if (mBar && 'IntersectionObserver' in window) {
    var hideFor = [quote, document.querySelector('.site-footer')].filter(Boolean);
    var visible = new Set();
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { if (e.isIntersecting) visible.add(e.target); else visible.delete(e.target); });
      mBar.classList.toggle('hide', visible.size > 0);
    });
    hideFor.forEach(function (el) { io.observe(el); });
  }

  // ---- Mobile menu ----
  var toggle = document.getElementById('navToggle');
  var nav = document.getElementById('siteNav');
  function closeNav() {
    if (!nav) return;
    nav.classList.remove('open'); document.body.classList.remove('nav-open');
    if (toggle) toggle.setAttribute('aria-expanded', 'false');
  }
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = !nav.classList.contains('open');
      if (open && header) nav.style.top = Math.max(0, header.getBoundingClientRect().bottom) + 'px';
      nav.classList.toggle('open', open); document.body.classList.toggle('nav-open', open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.addEventListener('click', function (e) { if (e.target.closest('a')) closeNav(); });
  }

  // ---- Services dropdown (click/tap + keyboard; hover on desktop) ----
  document.querySelectorAll('.has-sub').forEach(function (li) {
    var btn = li.querySelector('.nav-sub-btn');
    var set = function (open) { li.classList.toggle('open', open); btn.setAttribute('aria-expanded', open ? 'true' : 'false'); };
    btn.addEventListener('click', function () { set(!li.classList.contains('open')); });
    var fine = window.matchMedia('(hover:hover) and (min-width:961px)');
    li.addEventListener('mouseenter', function () { if (fine.matches) set(true); });
    li.addEventListener('mouseleave', function () { if (fine.matches) set(false); });
    li.addEventListener('focusout', function (e) { if (!li.contains(e.relatedTarget)) set(false); });
  });
  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    document.querySelectorAll('.has-sub.open').forEach(function (li) {
      li.classList.remove('open'); var b = li.querySelector('.nav-sub-btn'); b.setAttribute('aria-expanded', 'false'); b.focus();
    });
    if (nav && nav.classList.contains('open')) { closeNav(); toggle.focus(); }
  });

  // ---- Quote funnel -> Web3Forms (same two-step flow as the door hanger page) ----
  document.querySelectorAll('[data-funnel]').forEach(function (form) {
    var steps = {}; form.querySelectorAll('[data-step]').forEach(function (s) { steps[s.getAttribute('data-step')] = s; });
    var bar = form.querySelector('[data-fn-bar]'), lbl = form.querySelector('[data-fn-lbl]');
    var err1 = form.querySelector('[data-err="1"]'), err2 = form.querySelector('[data-err="2"]');
    var submit = form.querySelector('[data-submit]');

    function picked() {
      return Array.prototype.map.call(form.querySelectorAll('input[name="service"]:checked'), function (c) { return c.value; });
    }
    function go(n) {
      Object.keys(steps).forEach(function (k) { steps[k].hidden = String(n) !== k; });
      bar.style.width = n === 1 ? '50%' : '100%';
      lbl.textContent = n === 3 ? 'Done' : 'Step ' + n + ' of 2';
      var top = form.getBoundingClientRect().top;
      if (top < 0 || top > window.innerHeight * 0.6) form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    form.querySelectorAll('input[name="service"]').forEach(function (c) {
      c.addEventListener('change', function () { if (picked().length) err1.classList.remove('on'); });
    });
    form.querySelector('[data-next]').addEventListener('click', function () {
      var p = picked();
      if (!p.length) { err1.classList.add('on'); return; }
      var box = form.querySelector('[data-picked]'); box.innerHTML = '';
      p.forEach(function (v) { var s = document.createElement('span'); s.textContent = v; box.appendChild(s); });
      go(2);
      setTimeout(function () { form.elements['name'].focus({ preventScroll: true }); }, 350);
    });
    form.querySelector('[data-back]').addEventListener('click', function () { go(1); });

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var fields = ['name', 'phone', 'address'].map(function (n) { return form.elements[n]; });
      var ok = true, firstBad = null;
      fields.forEach(function (f) {
        var v = f.value.trim();
        var bad = !v || (f.name === 'phone' && v.replace(/\D/g, '').length < 10);
        f.classList.toggle('bad', bad); f.setAttribute('aria-invalid', bad ? 'true' : 'false');
        if (bad) { ok = false; if (!firstBad) firstBad = f; }
      });
      if (!ok) { err2.textContent = 'Please fill in your name, a valid phone number, and your address.'; err2.classList.add('on'); firstBad.focus(); return; }
      err2.classList.remove('on');
      if (form.elements['botcheck'] && form.elements['botcheck'].checked) return;

      var name = fields[0].value.trim();
      var fd = new FormData();
      fd.append('access_key', WEB3FORMS_KEY);
      fd.append('subject', 'New website quote request: ' + name);
      fd.append('from_name', 'procleansurfaces.com');
      fd.append('Name', name);
      fd.append('Phone', fields[1].value.trim());
      fd.append('Address', fields[2].value.trim());
      fd.append('Services', picked().join(', '));
      fd.append('Source', 'Website: ' + location.pathname);

      submit.disabled = true; submit.textContent = 'Sending…';
      fetch('https://api.web3forms.com/submit', { method: 'POST', headers: { 'Accept': 'application/json' }, body: fd })
        .then(function (r) { return r.json().catch(function () { return {}; }); })
        .then(function (j) {
          if (!j.success) throw new Error('fail');
          form.querySelector('[data-done-name]').textContent = ', ' + name.split(' ')[0];
          go(3); steps['3'].focus({ preventScroll: true });
          if (typeof window.gtag === 'function') window.gtag('event', 'generate_lead', { form: location.pathname });
        })
        .catch(function () {
          submit.disabled = false; submit.textContent = 'Get my free quote';
          err2.innerHTML = 'That didn’t go through. Your details are still here, so please try again, or call or text <a href="tel:+12253635220">(225) 363-5220</a>.';
          err2.classList.add('on');
        });
    });
  });

  // ---- Cal.com booking (contact page only; loads when scrolled near) ----
  var calEl = document.getElementById('my-cal-inline-pro-clean');
  if (calEl) {
    var calLoaded = false;
    var loadCal = function () {
      if (calLoaded) return; calLoaded = true;
      (function (C, A, L) { var p = function (a, ar) { a.q.push(ar); }; var d = C.document; C.Cal = C.Cal || function () { var cal = C.Cal; var ar = arguments; if (!cal.loaded) { cal.ns = {}; cal.q = cal.q || []; d.head.appendChild(d.createElement("script")).src = A; cal.loaded = true; } if (ar[0] === L) { var api = function () { p(api, arguments); }; var namespace = ar[1]; api.q = api.q || []; if (typeof namespace === "string") { cal.ns[namespace] = cal.ns[namespace] || api; p(cal.ns[namespace], ar); p(cal, ["initNamespace", namespace]); } else p(cal, ar); return; } p(cal, ar); }; })(window, "https://app.cal.com/embed/embed.js", "init");
      Cal("init", "pro-clean", { origin: "https://app.cal.com" });
      Cal.ns["pro-clean"]("inline", {
        elementOrSelector: "#my-cal-inline-pro-clean",
        config: { "layout": "month_view", "useSlotsViewOnSmallScreen": "true", "theme": "light" },
        calLink: "reid-scott-wp1rhh/pro-clean"
      });
      Cal.ns["pro-clean"]("ui", { "theme": "light", "hideEventTypeDetails": false, "layout": "month_view" });
      var ph = calEl.querySelector('.cal-loading');
      if (ph && 'MutationObserver' in window) {
        var mo = new MutationObserver(function () { if (calEl.querySelector('iframe')) { ph.remove(); mo.disconnect(); } });
        mo.observe(calEl, { childList: true });
      }
    };
    if ('IntersectionObserver' in window) {
      var cio = new IntersectionObserver(function (en) { if (en[0].isIntersecting) { loadCal(); cio.disconnect(); } }, { rootMargin: '600px' });
      cio.observe(calEl);
    } else { loadCal(); }
  }
})();
