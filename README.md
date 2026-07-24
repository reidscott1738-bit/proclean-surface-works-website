# Pro Clean Surface Works — website

Static HTML site for **Pro Clean Surface Works**, a pressure washing company in Baton Rouge, LA.
Built to rank locally for "pressure washing baton rouge" and related terms, and to feed the Google Business Profile / Map Pack.

- **Live domain:** https://procleansurfaces.com
- **Hosting:** Hostinger (static). Deploy is handled in hPanel → Advanced → Git (push, then click Deploy).
- **Stack:** hand-written static HTML + one shared stylesheet (`/css/site.css`) + self-hosted Inter font. No build step, no framework, no WordPress.

## Structure

```
index.html                         Home — targets "pressure washing baton rouge"
contact.html                       Contact + free-quote form
reviews.html                       Reviews (real testimonials + Google review CTA)
css/site.css                       Shared design system (edit once, applies everywhere)
fonts/inter-var.woff2              Self-hosted variable font (zero CLS)
images/logo.svg                    Brand mark / favicon
images/og-image.*                  Social share image (see "To do" below)
robots.txt, sitemap.xml, llms.txt  Technical SEO
.htaccess                          HTTPS + non-www redirect, caching, compression

Service pages (dirs):
  residential-pressure-washing-baton-rouge/
  commercial-pressure-washing-baton-rouge/
  house-washing-baton-rouge/
  driveway-cleaning-baton-rouge/
  sidewalk-cleaning-baton-rouge/
  power-washing-baton-rouge/

Location pages (dirs):
  pressure-washing-baton-rouge/
  pressure-washing-prairieville/
  pressure-washing-gonzales/
  pressure-washing-denham-springs/
  pressure-washing-geismar/
  pressure-washing-saint-gabriel/
```

## Editing

- **Design/colors/layout:** edit `css/site.css` — it's the single source of truth for every page.
- **Business facts** (phone, email, service list, areas) appear in each page's JSON-LD schema and footer. Keep them identical everywhere (NAP consistency matters for local ranking).
- Every page's phone is `(225) 302-9540` → `tel:+12253029540` / `sms:+12253029540`.

## Contact / NAP

- Pro Clean Surface Works
- (225) 302-9540 · procleansurfaceworks@gmail.com
- Baton Rouge, Louisiana
- Serving East Baton Rouge, Ascension, Livingston & Iberville parishes.
