# Pro Clean Surface Works — website

Static HTML site for **Pro Clean Surface Works**, a pressure washing company in Baton Rouge, LA.
Built to rank locally for "pressure washing baton rouge" and related terms, and to feed the Google Business Profile / Map Pack.

- **Live domain:** https://procleansurfaces.com
- **Hosting:** Hostinger (static). Deploy is handled in hPanel → Advanced → Git (push, then click Deploy).
- **Stack:** hand-written static HTML + one shared stylesheet (`/css/site.css`) + self-hosted Inter font. No build step, no framework, no WordPress.

## Structure

Pages are generated. **Edit the sources in `_build/pages/`, never the generated HTML**, then rebuild:

```
powershell -ExecutionPolicy Bypass -File _build\build.ps1
```

- `_build/pages/*.html` - one file per page: a JSON meta block (url, title, description, FAQs, schema hints) followed by the page body.
- `_build/build.ps1` - adds the shared header, footer, quote form, JSON-LD schema, breadcrumbs and FAQ markup, writes every page to the site root and regenerates `sitemap.xml`.
- Body placeholders: `<!--faq-->`, `<!--quote-->`, `<!--reviews-->`, `<!--areas-->`, `<!--services-->`, `<!--pair:key:lg-->`, `<!--work:key,key,key-->`, `<!--aside:Heading^Label|/url~Label|/url-->`, `<!--crumbs-->`.
- FAQ text lives only in the meta block, so the visible FAQ and the FAQPage schema always match.
- `css/site.css` - design system. `js/site.js` - menu, quote form (Web3Forms), lazy Cal.com embed.
- `doorhangers/` is hand-written (QR landing page, noindex) and is not generated.
- `_build/` is blocked in robots.txt and .htaccess.

Page types: home, 8 service pages, 9 town pages, 4 audience pages, 8 guides, our-work, about, contact, reviews, service-areas, resources, privacy, terms, 404, thankyou.
## Contact / NAP

- Pro Clean Surface Works
- (225) 363-5220 · procleansurfaceworks@gmail.com
- Baton Rouge, Louisiana
- Serving East Baton Rouge, Ascension, Livingston & Iberville parishes.
