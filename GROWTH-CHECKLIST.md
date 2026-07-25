# Pro Clean Surface Works — Ranking & Growth Checklist

Everything the website itself needs is DONE. This file covers the off-site work that
actually drives the Google Map Pack (top-3 local results). These require creating
accounts / real-world verification, so a person (you or a hired VA) must do them —
they can't be automated. Copy-paste blocks are provided so each takes ~5 minutes.

---

## ⭐ THE ONE THING THAT MATTERS MOST: Google Business Profile (GBP)

The Map Pack is ~80% Google Business Profile, reviews, and proximity — NOT the website.
Without a **verified** GBP you cannot appear in the map pack at all. Do this first.

1. Go to https://business.google.com → "Add your business".
2. Use the EXACT info in the NAP block below (must match the website word-for-word).
3. Primary category: **Pressure Washing Service**. Secondary: *Cleaning Service*.
4. Service-area business (you go to customers) — add: Baton Rouge, Prairieville, Gonzales,
   Denham Springs, Geismar, Saint Gabriel, Zachary, Central.
5. Add services (Driveway cleaning, House washing, Sidewalk cleaning, Commercial, etc.),
   your hours, and upload the real job photos (already in `/images/src/` in the repo).
6. **Verify** (video/phone/postcard). This is the bottleneck — start it immediately;
   verification can take a few days and nothing ranks in the map until it's done.
7. Set the website link to https://procleansurfaces.com

## ⭐ REVIEWS (second most important)

You have 2. Aim for 10+ fast. Text every happy customer your review link.
- Get your review link from the GBP dashboard ("Ask for reviews").
- Paste that link into `reviews.html` where it says `TODO: replace # with your ... link`
  (the "Leave a Google review" button) — tell me the link and I'll wire it in.

---

## NAP — use this EXACT text everywhere (consistency = ranking signal)

```
Business name: Pro Clean Surface Works
Phone:         (225) 302-9540
Email:         procleansurfaceworks@gmail.com
Website:       https://procleansurfaces.com
City:          Baton Rouge, Louisiana
Service area:  Baton Rouge, Prairieville, Gonzales, Denham Springs, Geismar,
               Saint Gabriel, Zachary, Central (East Baton Rouge, Ascension,
               Livingston & Iberville parishes)
Category:      Pressure Washing Service
Description:   Locally owned pressure washing and exterior surface cleaning in
               Baton Rouge, LA. Driveways, house washing, sidewalks, concrete, and
               commercial pressure washing. Free quotes. Pressure washing done right.
```

## Free citation sites (real "backlinks" for local SEO) — submit the NAP above

Each is a legitimate backlink + trust signal. Free. ~5 min each. Priority order:

1. Google Business Profile — https://business.google.com  (see above — #1 priority)
2. Bing Places — https://www.bingplaces.com  (can import from Google once GBP exists)
3. Apple Business Connect — https://businessconnect.apple.com
4. Yelp for Business — https://biz.yelp.com
5. Facebook Page — https://facebook.com/pages/create  (link the site + Instagram)
6. Nextdoor Business — https://business.nextdoor.com  (huge for neighborhood services)
7. Bing/Yahoo via Yelp — covered by #4
8. Angi — https://www.angi.com/companyaccount
9. Thumbtack — https://www.thumbtack.com/pro
10. BBB — https://www.bbb.org/get-a-quote  (Better Business Bureau listing)
11. HomeAdvisor / Houzz — optional
12. Local: Baton Rouge Area Chamber (brac.org), 225 Business directory

Tip: also post your job photos to the Instagram (@procleansurfaces) and TikTok
already linked on the site, and link back to procleansurfaces.com in each bio.

---

## Search engine indexing

- **Google Search Console** — https://search.google.com/search-console  → add
  procleansurfaces.com (verify via DNS or the HTML tag — I can add the tag if you paste it),
  then submit the sitemap: `https://procleansurfaces.com/sitemap.xml`
- **Bing Webmaster Tools** — https://www.bing.com/webmasters → import from GSC.
- **IndexNow** (already prepped — no account): after the site is live on Hostinger, ping:
  ```
  curl "https://api.indexnow.org/indexnow?url=https://procleansurfaces.com/&key=0ec2f9cb5cf14df0b6a08ffdc8dc623a"
  ```
  (The key file `0ec2f9cb5cf14df0b6a08ffdc8dc623a.txt` is already in the site root.)

---

## Quote-form email (FormSubmit) — ONE click left

The quote forms send to procleansurfaceworks@gmail.com via FormSubmit (no account needed).
An **activation email from FormSubmit is already sitting in that Gmail inbox** — open it and
click **"Activate Form"** once. After that, every quote request is emailed automatically.
Until then, phone/text still works with zero setup, so no lead is lost.
