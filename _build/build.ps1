# Pro Clean Surface Works - static page builder.
# Each file in _build/pages/ is one page: a JSON meta block in an HTML comment, then the page body.
# Run:  powershell -ExecutionPolicy Bypass -File _build\build.ps1
# Writes every page into the site root, plus sitemap.xml.

$ErrorActionPreference = 'Stop'
$Root  = Split-Path -Parent $PSScriptRoot
$Pages = Join-Path $PSScriptRoot 'pages'
$Site  = 'https://procleansurfaces.com'
$Today = (Get-Date).ToString('yyyy-MM-dd')
$utf8  = New-Object Text.UTF8Encoding $false
$CssV  = '20261018'

function Enc([string]$s) { [System.Net.WebUtility]::HtmlEncode($s) }

# ---------------------------------------------------------------- shared data
$Phone = '(225) 363-5220'; $Tel = 'tel:+12253635220'; $Sms = 'sms:+12253635220'
$Email = 'procleansurfaceworks@gmail.com'

$Services = @(
  @{ name='Driveway & concrete cleaning'; url='/driveway-cleaning-baton-rouge/'; blurb='Oil, tire marks, mildew and years of grime lifted out of concrete.' },
  @{ name='House washing & soft wash'; url='/house-washing-baton-rouge/'; blurb='Low-pressure soft wash for siding, brick and stucco.' },
  @{ name='Sidewalk & curb cleaning'; url='/sidewalk-cleaning-baton-rouge/'; blurb='Walkways, entries, steps and curbs brought back to clean.' },
  @{ name='Patio, porch & pool deck cleaning'; url='/patio-cleaning-baton-rouge/'; blurb='Mildew and dark staining cleared from outdoor living spaces.' },
  @{ name='Garbage can cleaning'; url='/garbage-can-cleaning-baton-rouge/'; blurb='Smelly, grimy trash cans washed out and rinsed clean.' },
  @{ name='Residential pressure washing'; url='/residential-pressure-washing-baton-rouge/'; blurb='The whole outside of your home in one visit.' },
  @{ name='Commercial pressure washing'; url='/commercial-pressure-washing-baton-rouge/'; blurb='Storefronts, sidewalks, dumpster pads and drive-thrus.' },
  @{ name='Power washing'; url='/power-washing-baton-rouge/'; blurb='Not sure what you need? Tell us the surface.' }
)

$Areas = [ordered]@{
  'East Baton Rouge Parish' = @(@('Baton Rouge','/pressure-washing-baton-rouge/'), @('Zachary','/pressure-washing-zachary/'), @('Central','/pressure-washing-central/'))
  'Ascension Parish'        = @(@('Prairieville','/pressure-washing-prairieville/'), @('Gonzales','/pressure-washing-gonzales/'), @('Geismar','/pressure-washing-geismar/'))
  'Livingston Parish'       = @(@('Denham Springs','/pressure-washing-denham-springs/'), @('Walker','/pressure-washing-walker/'))
  'Iberville Parish'        = @(,@('Saint Gabriel','/pressure-washing-saint-gabriel/'))
}

$Work = [ordered]@{
  'driveway-white'  = @('Driveway with brick border','Driveway and brick-edged front walk on a white brick home')
  'driveway-curb'   = @('Cul-de-sac driveway','Driveway, curb and street-side sidewalk')
  'entry'           = @('Front entry','Covered front entry')
  'patio'           = @('Covered back patio','Covered back patio')
  'sidewalk'        = @('Front sidewalk','Long front sidewalk')
  'driveway-brick'  = @('Driveway and brick apron','Driveway on a red brick home')
  'garage-apron'    = @('Garage apron','Driveway apron in front of the garage')
  'side-walk'       = @('Side walkway','Side walkway along the house')
  'porch-corner'    = @('Covered porch corner','Shaded corner of a covered porch')
  'driveway-corner' = @('Driveway corner','Corner-lot driveway')
}
$QuoteServices = @('Driveway cleaning','House soft wash','Sidewalk and curb cleaning','Garbage can cleaning','Patio or pool deck','Commercial property','Something else')

# ---------------------------------------------------------------- business schema node
$Business = [ordered]@{
  '@type' = @('LocalBusiness','HomeAndConstructionBusiness')
  '@id' = "$Site/#business"
  name = 'Pro Clean Surface Works'
  url = "$Site/"
  logo = "$Site/images/logo.png"
  image = "$Site/images/og-share.jpg"
  description = 'Locally owned pressure washing company in Baton Rouge, Louisiana. Driveway and concrete cleaning, house soft washing, sidewalk and curb cleaning, patio cleaning, garbage can cleaning and commercial pressure washing across East Baton Rouge, Ascension, Livingston and Iberville parishes.'
  slogan = 'Pressure washing done right.'
  telephone = '+1-225-363-5220'
  email = $Email
  address = [ordered]@{ '@type'='PostalAddress'; addressLocality='Baton Rouge'; addressRegion='LA'; postalCode='70808'; addressCountry='US' }
  areaServed = @(
    @{ '@type'='City'; name='Baton Rouge' }, @{ '@type'='City'; name='Prairieville' }, @{ '@type'='City'; name='Gonzales' },
    @{ '@type'='City'; name='Denham Springs' }, @{ '@type'='City'; name='Geismar' }, @{ '@type'='City'; name='Saint Gabriel' },
    @{ '@type'='City'; name='Zachary' }, @{ '@type'='City'; name='Central' }, @{ '@type'='City'; name='Walker' },
    @{ '@type'='AdministrativeArea'; name='East Baton Rouge Parish' }, @{ '@type'='AdministrativeArea'; name='Ascension Parish' },
    @{ '@type'='AdministrativeArea'; name='Livingston Parish' }, @{ '@type'='AdministrativeArea'; name='Iberville Parish' }
  )
  founder = @(
    @{ '@type'='Person'; name='Grayson Allain' }, @{ '@type'='Person'; name='Riley Allain' }, @{ '@type'='Person'; name='Reid Scott' }
  )
  knowsAbout = @('Pressure washing','Soft washing','House washing','Driveway cleaning','Concrete cleaning','Sidewalk and curb cleaning','Patio cleaning','Garbage can cleaning','Commercial pressure washing')
  hasOfferCatalog = [ordered]@{
    '@type'='OfferCatalog'; name='Exterior cleaning services'
    itemListElement = @($Services | ForEach-Object { [ordered]@{ '@type'='Offer'; itemOffered=[ordered]@{ '@type'='Service'; name=$_.name; url="$Site$($_.url)" } } })
  }
  aggregateRating = [ordered]@{ '@type'='AggregateRating'; ratingValue='5.0'; reviewCount='2'; bestRating='5' }
  sameAs = @('https://www.instagram.com/procleansurfaces')
}

# ---------------------------------------------------------------- partial renderers
function SecHead([string]$eyebrow, [string]$title, [string]$lead, [string]$id) {
  $l = if ($lead) { "<p class=`"lede`">$lead</p>" } else { '' }
  "<div class=`"sec-head`"><p class=`"label`">$eyebrow</p><h2 id=`"$id`" class=`"h2`">$title</h2>$l</div>"
}

function Render-Faq($faqs, $title) {
  if (-not $title) { $title = 'Common questions' }
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append("<section class=`"section faq-section`" aria-labelledby=`"faq-h`"><div class=`"container faq-wrap`">")
  [void]$sb.Append((SecHead 'Questions' (Enc $title) "Still unsure? Call or text <a href=`"$Tel`">$Phone</a>." 'faq-h'))
  [void]$sb.Append('<div class="faq">')
  foreach ($f in $faqs) { [void]$sb.Append("<details><summary>$(Enc $f[0])<span class=`"faq-x`" aria-hidden=`"true`"></span></summary><p>$(Enc $f[1])</p></details>") }
  [void]$sb.Append('</div></div></section>')
  $sb.ToString()
}

function Render-Pair([string]$key, [string]$size) {
  $cap = $Work[$key]
  $hero = $size -eq 'hero'; if ($hero) { $size = 'lg' }
  $load = if ($hero) { 'fetchpriority="high"' } else { 'loading="lazy"' }
  $sizes = if ($size -eq 'lg') { '(max-width:900px) 50vw, 300px' } else { '(max-width:900px) 50vw, 200px' }
  $img = { param($side) "<img src=`"/images/ba-$key-$side.webp`" srcset=`"/images/ba-$key-$side-420.webp 420w, /images/ba-$key-$side.webp 720w`" sizes=`"$sizes`" width=`"720`" height=`"900`" $load decoding=`"async`" alt=`"$(if($side -eq 'before'){'Before'}else{'After'}) cleaning: $(Enc $cap[1].ToLower())`">" }
  "<figure class=`"ba`"><div class=`"ba-pair`"><div class=`"ba-side`">$(& $img 'before')<span class=`"chip`">Before</span></div><div class=`"ba-side`">$(& $img 'after')<span class=`"chip chip-after`">After</span></div></div><figcaption><p class=`"ba-title`">$(Enc $cap[0])</p><p class=`"ba-meta`">Baton Rouge area</p></figcaption></figure>"
}

function Render-Work([string]$keys, [string]$heading) {
  $list = $keys.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  if (-not $heading) { $heading = 'See the difference' }
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append("<section class=`"section bg-alt`" aria-labelledby=`"work-h`"><div class=`"container`"><div class=`"sec-head-row`">")
  [void]$sb.Append((SecHead 'Real results' (Enc $heading) 'Real jobs from around Baton Rouge. Same surface, before and after.' 'work-h'))
  [void]$sb.Append("<a class=`"btn btn-outline`" href=`"/our-work/`">See all projects</a></div><div class=`"work-row`">")
  foreach ($k in $list) { [void]$sb.Append((Render-Pair $k 'sm')) }
  [void]$sb.Append('</div></div></section>')
  $sb.ToString()
}

function Render-Reviews {
  $head = SecHead 'What customers say about us' 'Hard working and professional' 'Our customers keep using the same words. <span class="stars" aria-hidden="true">&#9733;&#9733;&#9733;&#9733;&#9733;</span> 5.0 from local customers.' 'rev-h'
  @"
<section class="section" aria-labelledby="rev-h"><div class="container">$head
<div class="reviews-grid">
<blockquote class="review"><p>Excellent result. Pleased with the professionalism and hustle.</p><footer>Phillip Smith, Baton Rouge</footer></blockquote>
<blockquote class="review"><p>These young men are hard working and professional. The power washing was excellent.</p><footer>Pam Baker, Baton Rouge</footer></blockquote>
</div>
<p style="margin-top:28px"><a class="link-arrow" href="/reviews.html">Read our reviews</a></p>
</div></section>
"@
}

function Render-Areas {
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append('<div class="area-cols">')
  foreach ($p in $Areas.Keys) {
    [void]$sb.Append("<div><h3>$p</h3><ul>")
    foreach ($a in $Areas[$p]) { [void]$sb.Append("<li><a href=`"$($a[1])`">Pressure washing in $($a[0])</a></li>") }
    [void]$sb.Append('</ul></div>')
  }
  [void]$sb.Append('</div>')
  $sb.ToString()
}

function Render-Chips {
  $links = ($Areas.Values | ForEach-Object { $_ } | ForEach-Object { "<a href=`"$($_[1])`">$($_[0])</a>" }) -join ''
  "<div class=`"chips`">$links</div>"
}

function Render-ServiceList {
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append('<ul class="svc-list">')
  foreach ($s in $Services) { [void]$sb.Append("<li><a href=`"$($s.url)`"><span class=`"svc-t`"><b>$(Enc $s.name)</b><span>$(Enc $s.blurb)</span></span><span class=`"svc-go`" aria-hidden=`"true`">&rarr;</span></a></li>") }
  [void]$sb.Append('</ul>')
  $sb.ToString()
}

function Render-Quote([string]$heading, [string]$intro) {
  if (-not $heading) { $heading = 'Ready for a cleaner property?' }
  if (-not $intro) { $intro = 'Send a few details and we will get back to you within a day. Rather talk? Call or text (225) 363-5220.' }
  $ck = '<span class="ck"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></span>'
  $opts = @(
    @('Concrete & driveway cleaning','Concrete &amp; driveway','<path d="M4 21 8 3"/><path d="M20 21 16 3"/><path d="M12 5v2"/><path d="M12 11v2"/><path d="M12 17v2"/>'),
    @('House soft wash','House soft wash','<path d="m3 11 9-7 9 7"/><path d="M5 10v10h14V10"/><path d="M10 20v-6h4v6"/>'),
    @('Sidewalk & curb cleaning','Sidewalk &amp; curb','<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 10h18"/><path d="M3 15h18"/><path d="M12 4v6"/><path d="M8 10v5"/><path d="M16 10v5"/><path d="M12 15v5"/>'),
    @('Garbage can cleaning','Garbage can cleaning','<path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M5 6l1.2 14a2 2 0 0 0 2 2h7.6a2 2 0 0 0 2-2L19 6"/><path d="M10 11v6"/><path d="M14 11v6"/>')
  )
  $i = 0
  $tiles = ($opts | ForEach-Object { $i++; "<div class=`"svc-opt`"><input type=`"checkbox`" id=`"qs$i`" name=`"service`" value=`"$(Enc $_[0])`"><label for=`"qs$i`"><span class=`"ico`"><svg width=`"22`" height=`"22`" viewBox=`"0 0 24 24`" fill=`"none`" stroke=`"currentColor`" stroke-width=`"2`" stroke-linecap=`"round`" stroke-linejoin=`"round`" aria-hidden=`"true`">$($_[2])</svg></span><span class=`"nm`">$($_[1])</span>$ck</label></div>" }) -join ''
  @"
<section class="quote-band" id="quote" aria-labelledby="quote-h"><div class="container quote-grid">
<div class="quote-copy"><p class="label">Free quote</p><h2 id="quote-h" class="h2">$heading</h2><p class="lede">$intro</p>
<a class="btn btn-outline btn-lg" href="$Tel">Call now</a>
<ul class="quote-alt"><li><span>Call or text</span><a href="$Tel">$Phone</a></li><li><span>Email</span><a href="mailto:$Email">$Email</a></li></ul></div>
<form class="fn-box" data-funnel novalidate>
<div class="fn-progress" aria-hidden="true"><div class="bar"><i data-fn-bar></i></div><span data-fn-lbl>Step 1 of 2</span></div>
<div class="fn-step" data-step="1">
<h3>What do you need cleaned?</h3>
<p class="sub">Pick one or more.</p>
<fieldset class="svc-pick"><legend class="sr-only">Services</legend>$tiles</fieldset>
<p class="fn-err" data-err="1" role="alert">Pick at least one service to continue.</p>
<button type="button" class="btn btn-primary fn-btn" data-next>Next &rarr;</button>
</div>
<div class="fn-step" data-step="2" hidden>
<h3>Where should we send your quote?</h3>
<p class="sub">We&rsquo;ll call you with your price. No spam, ever.</p>
<div class="fn-picked" data-picked></div>
<div class="field"><label for="qName">Name</label><input id="qName" name="name" type="text" autocomplete="name" placeholder="Your name" required></div>
<div class="field"><label for="qPhone">Phone</label><input id="qPhone" name="phone" type="tel" inputmode="tel" autocomplete="tel" placeholder="(225) 555-0123" required></div>
<div class="field"><label for="qAddr">Address</label><input id="qAddr" name="address" type="text" autocomplete="street-address" placeholder="Street address &amp; city" required></div>
<input type="checkbox" name="botcheck" tabindex="-1" autocomplete="off" style="display:none" aria-hidden="true">
<p class="fn-err" data-err="2" role="alert">Please fill in your name, phone, and address.</p>
<button type="submit" class="btn btn-primary fn-btn" data-submit>Get my free quote</button>
<button type="button" class="fn-back" data-back>&larr; Back</button>
<p class="fn-fine">Free &amp; no obligation. We get back to you within a day.</p>
</div>
<div class="fn-step fn-done" data-step="3" hidden tabindex="-1">
<div class="fn-done-ico"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg></div>
<h3>We&rsquo;ll reach out with your quote as soon as possible<span data-done-name></span>!</h3>
<p>Thanks for requesting a free quote. Someone from our team will give you a call to go over your price.</p>
<p class="fn-done-small">Need us sooner? Call or text <a href="$Tel">$Phone</a>.</p>
</div>
</form>
</div></section>
"@
}

function Render-Aside([string]$spec) {
  $parts = $spec.Split('^')
  $head = if ($parts.Count -gt 1 -and $parts[0]) { $parts[0] } else { 'Related' }
  $links = ($parts[-1].Split('~') | Where-Object { $_ } | ForEach-Object { $p = $_.Split('|'); "<li><a href=`"$($p[1].Trim())`">$($p[0].Trim())</a></li>" }) -join ''
  @"
<aside class="aside" aria-label="Get a quote and related pages">
<div class="aside-card"><h2>Free quote</h2><p>Send a few details or text a photo. We get back to you within a day.</p><a class="btn btn-primary" href="#quote">Get a free quote</a><a class="btn btn-outline" href="$Tel">Call $Phone</a></div>
<nav class="aside-links" aria-label="$head"><h2>$head</h2><ul>$links</ul></nav>
</aside>
"@
}

# ---------------------------------------------------------------- chrome
$IcoPhone = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/></svg>'
$IcoMail = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>'
$IcoIg = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg>'

$NavItems = @(@('home','Home','/'), @('about','About','/about.html'), @('services','Services','/services/'), @('projects','Projects','/our-work/'), @('contact','Contact','/contact.html'))
function Render-Header([string]$current) {
  $items = ($NavItems | ForEach-Object { $cur = if ($_[0] -eq $current) { ' aria-current="page"' } else { '' }; "<li><a href=`"$($_[2])`"$cur>$($_[1])</a></li>" }) -join ''
  @"
<a class="skip-link" href="#content">Skip to content</a>
<div class="cbar"><div class="cbar-in"><a href="$Tel">$IcoPhone $Phone</a><a class="cbar-email" href="mailto:$Email">$IcoMail $Email</a><a class="cbar-social" href="https://www.instagram.com/procleansurfaces" rel="noopener" target="_blank">$IcoIg Instagram</a></div></div>
<header class="site-header" id="top">
<div class="container hdr">
<a href="/" class="hdr-logo" aria-label="Pro Clean Surface Works home"><img src="/images/logo.webp" alt="Pro Clean Surface Works" width="170" height="36"></a>
<nav class="hdr-nav" id="siteNav" aria-label="Main">
<ul class="nav-list">$items
<li class="nav-m"><a href="/service-areas.html">Service areas</a></li>
<li class="nav-m"><a href="/reviews.html">Reviews</a></li>
<li class="nav-m"><a href="/resources.html">Guides</a></li>
<li class="nav-m nav-call"><a href="$Tel">Call or text $Phone</a></li>
</ul>
</nav>
<div class="hdr-act">
<a class="btn btn-primary" href="#quote">Get free quote</a>
<button type="button" class="nav-toggle" id="navToggle" aria-expanded="false" aria-controls="siteNav"><span class="sr-only">Menu</span><span class="bars" aria-hidden="true"></span></button>
</div>
</div>
</header>
"@
}

$AreaFoot = ($Areas.Values | ForEach-Object { $_ } | ForEach-Object { "<li><a href=`"$($_[1])`">$($_[0])</a></li>" }) -join ''
$SvcFoot = ($Services | ForEach-Object { "<li><a href=`"$($_.url)`">$(Enc $_.name)</a></li>" }) -join ''
$Footer = @"
<footer class="site-footer">
<div class="container ftr">
<div class="ftr-brand"><a href="/" class="ftr-logo"><img src="/images/logo.webp" alt="Pro Clean Surface Works" width="200" height="42" loading="lazy"></a>
<p>Professional exterior cleaning for Baton Rouge homes and businesses. Driveways, houses, sidewalks and garbage cans, done right.</p>
<p class="ftr-nap"><strong>Pro Clean Surface Works</strong><br>Baton Rouge, LA<br><a href="$Tel">$Phone</a><br><a href="mailto:$Email">$Email</a><br><a href="https://www.instagram.com/procleansurfaces" rel="noopener" target="_blank">Instagram</a></p>
<p style="margin-top:20px"><a class="btn btn-primary" href="#quote">Get free quote</a></p></div>
<div><h2 class="ftr-h">Services</h2><ul><li><a href="/services/">All services</a></li>$SvcFoot</ul></div>
<div><h2 class="ftr-h">Service areas</h2><ul>$AreaFoot<li><a href="/service-areas.html">All service areas</a></li></ul></div>
<div><h2 class="ftr-h">Company</h2><ul><li><a href="/about.html">About</a></li><li><a href="/our-work/">Projects</a></li><li><a href="/reviews.html">Reviews</a></li><li><a href="/resources.html">Guides</a></li><li><a href="/contact.html">Contact</a></li></ul>
<h2 class="ftr-h ftr-h2">Who we help</h2><ul><li><a href="/pressure-washing-for-realtors-baton-rouge/">Realtors &amp; home sellers</a></li><li><a href="/pressure-washing-for-property-managers-baton-rouge/">Property managers</a></li><li><a href="/pressure-washing-for-hoas-baton-rouge/">HOAs &amp; neighborhoods</a></li><li><a href="/pressure-washing-for-restaurants-baton-rouge/">Restaurants</a></li></ul></div>
</div>
<div class="ftr-base"><div><span>&copy; 2026 Pro Clean Surface Works. Serving the Baton Rouge area.</span><span><a href="/privacy.html">Privacy</a><a href="/terms.html">Terms</a></span></div></div>
</footer>
<div class="m-bar" id="mBar"><a href="$Tel" class="m-call">Call now</a><a href="#quote" class="m-quote">Free quote</a></div>
<script src="/js/site.js?v=$CssV" defer></script>
"@

# ---------------------------------------------------------------- build loop
$sitemap = New-Object Text.StringBuilder
[void]$sitemap.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sitemap.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
$built = 0

foreach ($file in Get-ChildItem $Pages -Filter *.html | Sort-Object Name) {
  $raw = [IO.File]::ReadAllText($file.FullName, $utf8)
  $m = [regex]::Match($raw, '(?s)^\s*<!--(.*?)-->\s*(.*)$')
  if (-not $m.Success) { throw "No meta block in $($file.Name)" }
  $meta = $m.Groups[1].Value | ConvertFrom-Json
  $body = $m.Groups[2].Value
  $url = "$Site$($meta.url)"

  # body placeholders
  if ($meta.faqs) { $body = $body.Replace('<!--faq-->', (Render-Faq $meta.faqs $meta.faqTitle)) }
  $body = [regex]::Replace($body, '<!--aside:([^>]*)-->', { param($x) Render-Aside $x.Groups[1].Value })
  $body = $body.Replace('<!--chips-->', (Render-Chips)).Replace('<!--reviews-->', (Render-Reviews)).Replace('<!--areas-->', (Render-Areas)).Replace('<!--services-->', (Render-ServiceList))
  $body = [regex]::Replace($body, '<!--quote(?:\|([^|]*)\|([^>]*))?-->', { param($x) Render-Quote $x.Groups[1].Value $x.Groups[2].Value })
  $body = [regex]::Replace($body, '<!--work:([a-z,-]+)(?:\|([^>]*))?-->', { param($x) Render-Work $x.Groups[1].Value $x.Groups[2].Value })
  $body = [regex]::Replace($body, '<!--pair:([a-z-]+)(?::(lg|sm|hero))?-->', { param($x) $s = if ($x.Groups[2].Value) { $x.Groups[2].Value } else { 'lg' }; Render-Pair $x.Groups[1].Value $s })
  if ($body -match '<!--(?!crumbs)[a-z]+[:|-]') { Write-Warning "Unrendered placeholder in $($file.Name)" }

  # breadcrumbs
  $crumbHtml = ''; $crumbLd = $null
  if ($meta.url -ne '/') {
    $items = @(,@('Home','/'))
    if ($meta.crumbs) { foreach ($c in $meta.crumbs) { $items += ,@($c[0], $c[1]) } }
    $items += ,@($meta.crumb, $meta.url)
    $parts = @(); $ld = @(); $i = 1
    foreach ($it in $items) {
      if ($i -lt $items.Count) { $parts += "<a href=`"$($it[1])`">$(Enc $it[0])</a>" } else { $parts += "<span aria-current=`"page`">$(Enc $it[0])</span>" }
      $ld += [ordered]@{ '@type'='ListItem'; position=$i; name=$it[0]; item="$Site$($it[1])" }; $i++
    }
    $crumbHtml = "<nav class=`"crumbs`" aria-label=`"Breadcrumb`">$($parts -join '<span class="sep" aria-hidden="true">/</span>')</nav>"
    $crumbLd = [ordered]@{ '@type'='BreadcrumbList'; '@id'="$url#breadcrumb"; itemListElement=$ld }
  }
  $body = $body.Replace('<!--crumbs-->', $crumbHtml)

  # structured data
  $graph = New-Object System.Collections.ArrayList
  [void]$graph.Add($Business)
  [void]$graph.Add([ordered]@{ '@type'='WebSite'; '@id'="$Site/#website"; url="$Site/"; name='Pro Clean Surface Works'; inLanguage='en-US'; publisher=@{ '@id'="$Site/#business" } })
  $pageType = if ($meta.schemaType) { $meta.schemaType } else { 'WebPage' }
  $wp = [ordered]@{ '@type'=$pageType; '@id'="$url#webpage"; url=$url; name=$meta.title; description=$meta.description; isPartOf=@{ '@id'="$Site/#website" }; about=@{ '@id'="$Site/#business" }; inLanguage='en-US' }
  if ($crumbLd) { $wp.breadcrumb = @{ '@id'="$url#breadcrumb" } }
  if ($meta.image) { $wp.primaryImageOfPage = "$Site$($meta.image)" }
  [void]$graph.Add($wp)
  if ($crumbLd) { [void]$graph.Add($crumbLd) }
  if ($meta.service) {
    $svc = [ordered]@{ '@type'='Service'; '@id'="$url#service"; name=$meta.service.name; serviceType=$meta.service.type; description=$meta.description; url=$url; provider=@{ '@id'="$Site/#business" } }
    if ($meta.service.area) { $svc.areaServed = @{ '@type'='City'; name=$meta.service.area } } else { $svc.areaServed = $Business.areaServed }
    if ($meta.service.audience) { $svc.audience = @{ '@type'='Audience'; audienceType=$meta.service.audience } }
    [void]$graph.Add($svc)
  }
  if ($meta.article) {
    [void]$graph.Add([ordered]@{ '@type'='Article'; '@id'="$url#article"; headline=$meta.h1; description=$meta.description; datePublished=$meta.article.published; dateModified=$Today; author=@{ '@type'='Organization'; name='Pro Clean Surface Works'; url="$Site/" }; publisher=@{ '@id'="$Site/#business" }; mainEntityOfPage=@{ '@id'="$url#webpage" }; image="$Site$(if($meta.image){$meta.image}else{'/images/og-share.jpg'})" })
  }
  if ($meta.faqs) {
    [void]$graph.Add([ordered]@{ '@type'='FAQPage'; '@id'="$url#faq"; mainEntity=@($meta.faqs | ForEach-Object { [ordered]@{ '@type'='Question'; name=$_[0]; acceptedAnswer=[ordered]@{ '@type'='Answer'; text=$_[1] } } }) })
  }
  if ($meta.people) {
    foreach ($p in $meta.people) { [void]$graph.Add([ordered]@{ '@type'='Person'; name=$p; jobTitle='Co-founder'; worksFor=@{ '@id'="$Site/#business" }; homeLocation=@{ '@type'='City'; name='Baton Rouge' } }) }
  }
  if ($meta.reviews) {
    foreach ($r in $meta.reviews) { [void]$graph.Add([ordered]@{ '@type'='Review'; author=@{ '@type'='Person'; name=$r[0] }; reviewBody=$r[1]; datePublished=$r[2]; reviewRating=@{ '@type'='Rating'; ratingValue='5'; bestRating='5' }; itemReviewed=@{ '@id'="$Site/#business" } }) }
  }
  $ldJson = (@{ '@context'='https://schema.org'; '@graph'=$graph } | ConvertTo-Json -Depth 30 -Compress)

  $robots = if ($meta.noindex) { 'noindex,follow' } else { 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1' }
  $ogImg = if ($meta.ogImage) { $meta.ogImage } else { '/images/og-share.jpg' }
  $preload = ''
  if ($meta.preload) { $preload = "<link rel=`"preload`" as=`"image`" href=`"$($meta.preload.href)`" imagesrcset=`"$($meta.preload.srcset)`" imagesizes=`"$($meta.preload.sizes)`" fetchpriority=`"high`">" }
  $navKey = if ($meta.nav) { $meta.nav } elseif ($meta.url -eq '/') { 'home' } elseif ($meta.type -eq 'service') { 'services' } elseif ($meta.url -eq '/our-work/') { 'projects' } elseif ($meta.url -eq '/about.html') { 'about' } elseif ($meta.url -eq '/contact.html') { 'contact' } else { '' }
  $bodyClass = if ($meta.type) { "page-$($meta.type)" } else { 'page' }

  $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>$(Enc $meta.title)</title>
<meta name="description" content="$(Enc $meta.description)">
<link rel="canonical" href="$url">
<meta name="robots" content="$robots">
<meta name="theme-color" content="#303030">
<meta name="geo.region" content="US-LA">
<meta name="geo.placename" content="Baton Rouge, Louisiana">
<meta property="og:type" content="$(if($meta.article){'article'}else{'website'})">
<meta property="og:site_name" content="Pro Clean Surface Works">
<meta property="og:locale" content="en_US">
<meta property="og:url" content="$url">
<meta property="og:title" content="$(Enc $meta.title)">
<meta property="og:description" content="$(Enc $meta.description)">
<meta property="og:image" content="$Site$ogImg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="$(Enc $meta.title)">
<meta name="twitter:description" content="$(Enc $meta.description)">
<meta name="twitter:image" content="$Site$ogImg">
<link rel="preload" as="font" type="font/woff2" href="/fonts/barlow-400.woff2" crossorigin>
<link rel="preload" as="font" type="font/woff2" href="/fonts/barlow-sc-800i.woff2" crossorigin>
$preload
<link rel="icon" href="/images/logo.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/images/logo.png">
<link rel="stylesheet" href="/css/site.css?v=$CssV">
<script type="application/ld+json">$ldJson</script>
</head>
<body class="$bodyClass">
$(Render-Header $navKey)
<main id="content">
$($body.Trim())
</main>
$Footer
</body>
</html>
"@
  $html = [regex]::Replace($html, "(?m)^\s*\r?\n", '')
  $outPath = Join-Path $Root $meta.out
  New-Item -ItemType Directory -Force (Split-Path $outPath) | Out-Null
  [IO.File]::WriteAllText($outPath, $html, $utf8)
  $built++

  if (-not $meta.noindex) {
    $pri = if ($meta.priority) { $meta.priority } else { '0.7' }
    [void]$sitemap.AppendLine("  <url><loc>$url</loc><lastmod>$Today</lastmod><changefreq>$(if($meta.changefreq){$meta.changefreq}else{'monthly'})</changefreq><priority>$pri</priority></url>")
  }
}
[void]$sitemap.AppendLine('</urlset>')
[IO.File]::WriteAllText((Join-Path $Root 'sitemap.xml'), $sitemap.ToString(), $utf8)
"Built $built pages"
