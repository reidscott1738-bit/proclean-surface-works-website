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
$CssV  = '20261016'

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
  'driveway-white'  = 'Driveway and brick-edged front walk on a white brick home'
  'driveway-curb'   = 'Driveway, curb and street-side sidewalk'
  'entry'           = 'Covered front entry'
  'patio'           = 'Covered back patio'
  'sidewalk'        = 'Long front sidewalk'
  'driveway-brick'  = 'Driveway on a red brick home'
  'garage-apron'    = 'Driveway apron in front of the garage'
  'side-walk'       = 'Side walkway along the house'
  'porch-corner'    = 'Shaded corner of a covered porch'
  'driveway-corner' = 'Corner-lot driveway'
}

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
  priceRange = '$$'
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
function Render-Faq($faqs, $title) {
  if (-not $title) { $title = 'Common questions' }
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append("<section class=`"section faq-section`" aria-labelledby=`"faq-h`"><div class=`"container faq-wrap`"><div class=`"faq-head`"><p class=`"label`">Questions</p><h2 id=`"faq-h`" class=`"h2`">$(Enc $title)</h2><p>Still unsure? Call or text <a href=`"$Tel`">$Phone</a>.</p></div><div class=`"faq`">")
  foreach ($f in $faqs) { [void]$sb.Append("<details><summary>$(Enc $f[0])<span class=`"faq-x`" aria-hidden=`"true`"></span></summary><p>$(Enc $f[1])</p></details>") }
  [void]$sb.Append('</div></div></section>')
  $sb.ToString()
}

function Render-Pair([string]$key, [string]$size) {
  $cap = $Work[$key]
  $hero = $size -eq 'hero'; if ($hero) { $size = 'lg' }
  $load = if ($hero) { 'fetchpriority="high"' } else { 'loading="lazy"' }
  $sizes = if ($size -eq 'lg') { '(max-width:760px) 50vw, 360px' } else { '(max-width:760px) 50vw, 260px' }
  $img = { param($side) "<img src=`"/images/ba-$key-$side.webp`" srcset=`"/images/ba-$key-$side-420.webp 420w, /images/ba-$key-$side.webp 720w`" sizes=`"$sizes`" width=`"720`" height=`"900`" $load decoding=`"async`" alt=`"$(if($side -eq 'before'){'Before'}else{'After'}) cleaning: $(Enc $cap.ToLower())`">" }
  "<figure class=`"pair pair-$size`"><div class=`"pair-imgs`"><div class=`"pair-side`">$(& $img 'before')<span class=`"tag`">Before</span></div><div class=`"pair-side`">$(& $img 'after')<span class=`"tag tag-after`">After</span></div></div><figcaption>$(Enc $cap)</figcaption></figure>"
}

function Render-Work([string]$keys, [string]$heading) {
  $list = $keys.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  if (-not $heading) { $heading = 'Recent work from our crew' }
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append("<section class=`"section work-strip`" aria-labelledby=`"work-h`"><div class=`"container`"><div class=`"work-head`"><div><p class=`"label`">Our work</p><h2 id=`"work-h`" class=`"h2`">$(Enc $heading)</h2></div><a class=`"link-arrow`" href=`"/our-work/`">See all our before &amp; after photos</a></div><div class=`"work-row`">")
  foreach ($k in $list) { [void]$sb.Append((Render-Pair $k 'sm')) }
  [void]$sb.Append('</div></div></section>')
  $sb.ToString()
}

function Render-Reviews {
  @"
<section class="section reviews-band" aria-labelledby="rev-h"><div class="container reviews-grid">
<div class="reviews-head"><p class="label">Reviews</p><h2 id="rev-h" class="h2">What customers have said</h2><p class="rating-line"><span class="stars" aria-hidden="true">&#9733;&#9733;&#9733;&#9733;&#9733;</span> 5.0 from local customers</p><a class="link-arrow" href="/reviews.html">Read our reviews</a></div>
<blockquote class="review"><p>&ldquo;Excellent result. Pleased with the professionalism and hustle.&rdquo;</p><footer>Phillip Smith, Baton Rouge</footer></blockquote>
<blockquote class="review"><p>&ldquo;These young men are hard working and professional. The power washing was excellent.&rdquo;</p><footer>Pam Baker, Baton Rouge</footer></blockquote>
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

function Render-ServiceList {
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append('<ul class="svc-list">')
  $i = 1
  foreach ($s in $Services) { [void]$sb.Append("<li><a href=`"$($s.url)`"><span class=`"svc-n`">0$i</span><span class=`"svc-t`"><b>$(Enc $s.name)</b><span>$(Enc $s.blurb)</span></span><span class=`"svc-go`" aria-hidden=`"true`">&rarr;</span></a></li>"); $i++ }
  [void]$sb.Append('</ul>')
  $sb.ToString()
}

function Render-Quote([string]$heading, [string]$intro) {
  if (-not $heading) { $heading = 'Get a free quote' }
  if (-not $intro) { $intro = 'Tell us what needs cleaning and where. We&rsquo;ll get back to you with a price, usually the same day. Free, with no obligation to book.' }
  $opts = ($Services | Where-Object { $_.name -ne 'Residential pressure washing' -and $_.name -ne 'Power washing' } | ForEach-Object { "<option>$(Enc $_.name)</option>" }) -join ''
  @"
<section class="quote-band" id="quote" aria-labelledby="quote-h"><div class="container quote-grid">
<div class="quote-copy"><p class="label label-light">Free quote</p><h2 id="quote-h" class="h2">$heading</h2><p>$intro</p>
<ul class="quote-alt"><li><span>Call</span><a href="$Tel">$Phone</a></li><li><span>Text a photo</span><a href="$Sms">$Phone</a></li><li><span>Email</span><a href="mailto:$Email">$Email</a></li></ul></div>
<form class="qform" data-quote-form novalidate>
<div class="qf-row"><div class="qf"><label for="q-name">Name</label><input id="q-name" name="name" type="text" autocomplete="name" required><p class="qf-err" id="q-name-err">Please enter your name.</p></div>
<div class="qf"><label for="q-phone">Phone</label><input id="q-phone" name="phone" type="tel" inputmode="tel" autocomplete="tel" required><p class="qf-err" id="q-phone-err">Please enter a 10-digit phone number.</p></div></div>
<div class="qf"><label for="q-addr">Address or town</label><input id="q-addr" name="address" type="text" autocomplete="street-address" required><p class="qf-err" id="q-addr-err">Please enter an address or town so we can price it.</p></div>
<div class="qf"><label for="q-svc">What needs cleaning?</label><select id="q-svc" name="service"><option>Not sure yet</option>$opts<option>Several of these</option></select></div>
<div class="qf"><label for="q-msg">Anything else? <span class="opt">(optional)</span></label><textarea id="q-msg" name="message" rows="3"></textarea></div>
<input type="checkbox" name="botcheck" class="hp" tabindex="-1" autocomplete="off" aria-hidden="true">
<button type="submit" class="btn btn-primary btn-block">Send my quote request</button>
<p class="qf-status" role="status" aria-live="polite"></p>
<p class="qf-fine">We only use your details to reply about your quote.</p>
</form>
<div class="qform-done" hidden tabindex="-1"><h3>Thanks, we&rsquo;ve got it.</h3><p>We&rsquo;ll reach out with your quote as soon as possible. Need us sooner? Call or text <a href="$Tel">$Phone</a>.</p></div>
</div></section>
"@
}

function Render-Aside([string]$spec) {
  $parts = $spec.Split('^')
  $head = if ($parts.Count -gt 1 -and $parts[0]) { $parts[0] } else { 'Related' }
  $links = ($parts[-1].Split('~') | Where-Object { $_ } | ForEach-Object { $p = $_.Split('|'); "<li><a href=`"$($p[1].Trim())`">$($p[0].Trim())</a></li>" }) -join ''
  @"
<aside class="aside" aria-label="Get a quote and related pages">
<div class="aside-card"><h2>Free quote, usually same day</h2><p>Text a couple of photos and we&rsquo;ll send a price. No obligation.</p><a class="btn btn-primary" href="#quote">Get a free quote</a><a class="btn btn-ghost" href="$Tel">Call $Phone</a></div>
<nav class="aside-links" aria-label="$head"><h2>$head</h2><ul>$links</ul></nav>
</aside>
"@
}

# ---------------------------------------------------------------- chrome
$SvcMenu = ($Services | ForEach-Object { "<li><a href=`"$($_.url)`">$(Enc $_.name)</a></li>" }) -join ''
$Header = @"
<a class="skip-link" href="#content">Skip to content</a>
<header class="site-header" id="top">
<div class="container hdr">
<a href="/" class="hdr-logo" aria-label="Pro Clean Surface Works home"><img src="/images/logo.webp" alt="Pro Clean Surface Works" width="141" height="30"></a>
<nav class="hdr-nav" id="siteNav" aria-label="Main">
<ul class="nav-list">
<li class="has-sub"><button type="button" class="nav-sub-btn" aria-expanded="false" aria-controls="svcMenu">Services</button><ul class="nav-sub" id="svcMenu">$SvcMenu</ul></li>
<li><a href="/our-work/">Our work</a></li>
<li><a href="/service-areas.html">Service areas</a></li>
<li><a href="/about.html">About</a></li>
<li><a href="/reviews.html">Reviews</a></li>
<li class="nav-m"><a href="/resources.html">Guides</a></li>
<li class="nav-m"><a href="/contact.html">Contact</a></li>
<li class="nav-m nav-call"><a href="$Tel">Call or text $Phone</a></li>
</ul>
</nav>
<div class="hdr-act">
<a class="hdr-phone" href="$Tel"><span class="hdr-phone-l">Call or text</span> $Phone</a>
<a class="btn btn-primary btn-sm" href="#quote">Free quote</a>
<button type="button" class="nav-toggle" id="navToggle" aria-expanded="false" aria-controls="siteNav"><span class="sr-only">Menu</span><span class="bars" aria-hidden="true"></span></button>
</div>
</div>
</header>
"@

$AreaFoot = ($Areas.Values | ForEach-Object { $_ } | ForEach-Object { "<li><a href=`"$($_[1])`">$($_[0])</a></li>" }) -join ''
$SvcFoot = ($Services | ForEach-Object { "<li><a href=`"$($_.url)`">$(Enc $_.name)</a></li>" }) -join ''
$Footer = @"
<footer class="site-footer">
<div class="container ftr">
<div class="ftr-brand"><a href="/" class="ftr-logo"><img src="/images/logo.webp" alt="Pro Clean Surface Works" width="150" height="32" loading="lazy"></a>
<p>Pressure washing and exterior cleaning in Baton Rouge, Louisiana. Locally owned by Grayson Allain, Riley Allain and Reid Scott.</p>
<p class="ftr-nap"><strong>Pro Clean Surface Works</strong><br>Baton Rouge, LA<br><a href="$Tel">$Phone</a><br><a href="mailto:$Email">$Email</a></p></div>
<div><h2 class="ftr-h">Services</h2><ul>$SvcFoot</ul></div>
<div><h2 class="ftr-h">Service areas</h2><ul>$AreaFoot<li><a href="/service-areas.html">All service areas</a></li></ul></div>
<div><h2 class="ftr-h">Company</h2><ul><li><a href="/about.html">About us</a></li><li><a href="/our-work/">Our work</a></li><li><a href="/reviews.html">Reviews</a></li><li><a href="/resources.html">Guides</a></li><li><a href="/contact.html">Contact</a></li><li><a href="https://www.instagram.com/procleansurfaces" rel="noopener" target="_blank">Instagram</a></li></ul>
<h2 class="ftr-h ftr-h2">Who we help</h2><ul><li><a href="/pressure-washing-for-realtors-baton-rouge/">Realtors &amp; home sellers</a></li><li><a href="/pressure-washing-for-property-managers-baton-rouge/">Property managers</a></li><li><a href="/pressure-washing-for-hoas-baton-rouge/">HOAs &amp; neighborhoods</a></li><li><a href="/pressure-washing-for-restaurants-baton-rouge/">Restaurants</a></li></ul></div>
</div>
<div class="container ftr-base"><p>&copy; 2026 Pro Clean Surface Works. Pressure washing in Baton Rouge, Louisiana.</p><p><a href="/privacy.html">Privacy</a> <a href="/terms.html">Terms</a></p></div>
</footer>
<div class="m-bar" id="mBar"><a href="$Tel" class="m-call">Call $Phone</a><a href="#quote" class="m-quote">Free quote</a></div>
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
  $body = $body.Replace('<!--reviews-->', (Render-Reviews)).Replace('<!--areas-->', (Render-Areas)).Replace('<!--services-->', (Render-ServiceList))
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
<meta name="theme-color" content="#0E1E2A">
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
<link rel="preload" as="font" type="font/woff2" href="/fonts/inter-var.woff2" crossorigin>
$preload
<link rel="icon" href="/images/logo.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/images/logo.png">
<link rel="stylesheet" href="/css/site.css?v=$CssV">
<script type="application/ld+json">$ldJson</script>
</head>
<body class="$bodyClass">
$Header
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
