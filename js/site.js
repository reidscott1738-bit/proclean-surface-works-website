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

  // ---- Quote forms -> Web3Forms ----
  document.querySelectorAll('[data-quote-form]').forEach(function (form) {
    var status = form.querySelector('.qf-status');
    var btn = form.querySelector('button[type="submit"]');
    var done = form.parentNode.querySelector('.qform-done');
    var label = btn.textContent;

    function check(input) {
      var v = input.value.trim(), bad = !v;
      if (input.name === 'phone') bad = v.replace(/\D/g, '').length < 10;
      input.setAttribute('aria-invalid', bad ? 'true' : 'false');
      var err = document.getElementById(input.id + '-err');
      if (err) { if (bad) input.setAttribute('aria-describedby', err.id); else input.removeAttribute('aria-describedby'); }
      return !bad;
    }
    form.querySelectorAll('[required]').forEach(function (i) {
      i.addEventListener('blur', function () { if (i.value) check(i); });
      i.addEventListener('input', function () { if (i.getAttribute('aria-invalid') === 'true') check(i); });
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      status.textContent = '';
      var firstBad = null;
      form.querySelectorAll('[required]').forEach(function (i) { if (!check(i) && !firstBad) firstBad = i; });
      if (firstBad) { firstBad.focus(); return; }
      if (form.elements['botcheck'] && form.elements['botcheck'].checked) return;

      var fd = new FormData();
      fd.append('access_key', WEB3FORMS_KEY);
      fd.append('subject', 'New website quote request: ' + form.elements['name'].value.trim());
      fd.append('from_name', 'procleansurfaces.com');
      fd.append('Name', form.elements['name'].value.trim());
      fd.append('Phone', form.elements['phone'].value.trim());
      fd.append('Address', form.elements['address'].value.trim());
      fd.append('Service', form.elements['service'].value);
      if (form.elements['message'].value.trim()) fd.append('Message', form.elements['message'].value.trim());
      fd.append('Page', location.pathname);

      btn.disabled = true; btn.textContent = 'Sending…';
      fetch('https://api.web3forms.com/submit', { method: 'POST', headers: { 'Accept': 'application/json' }, body: fd })
        .then(function (r) { return r.json().catch(function () { return {}; }); })
        .then(function (j) {
          if (!j.success) throw new Error('fail');
          form.hidden = true;
          if (done) { done.hidden = false; done.focus(); }
          if (typeof window.gtag === 'function') window.gtag('event', 'generate_lead', { form: location.pathname });
        })
        .catch(function () {
          btn.disabled = false; btn.textContent = label;
          status.innerHTML = 'That didn’t go through. Your details are still here, so please try again, or call or text <a href="tel:+12253635220">(225) 363-5220</a>.';
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
