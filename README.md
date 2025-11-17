# LibreCrawl

A web-based multi-tenant crawler for SEO analysis and website auditing.

🌐 **Website**: [librecrawl.com](https://librecrawl.com)
**Try the Live Demo:** [crawl.librecrawl.com](https://crawl.librecrawl.com/)

## What it does

LibreCrawl crawls websites and gives you detailed information about pages, links, SEO elements, and performance. It's built as a web application using Python Flask with a modern web interface supporting multiple concurrent users.

## Features

- 🚀 **Multi-tenancy** - Multiple users can crawl simultaneously with isolated sessions
- 🎨 **Custom CSS styling** - Personalize the UI with your own CSS themes
- 💾 **Browser localStorage persistence** - Settings saved per browser
- 🔄 **JavaScript rendering** for dynamic content (React, Vue, Angular, etc.)
- 📊 **SEO analysis** - Extract titles, meta descriptions, headings, etc.
- 🔗 **Link analysis** - Track internal and external links with detailed relationship mapping
- 📈 **PageSpeed Insights integration** - Analyze Core Web Vitals
- 💾 **Multiple export formats** - CSV, JSON, or XML
- 🔍 **Issue detection** - Automated SEO issue identification
- ⚡ **Real-time crawling progress** with live statistics
- 🔐 **Self-hosted admin mode** - Authentication screens removed; LibreCrawl auto-provisions an admin session for private networks

## Getting started

### Requirements

- Python 3.8 or later
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. Clone or download this repository

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. For JavaScript rendering support (optional):
```bash
playwright install chromium
```

4. Run the application (self-hosted admin mode):
```bash
python main.py
# Legacy flag (prints the same info, retained for compatibility)
python main.py --local
```

5. Open your browser and navigate to:
   - Local: `http://localhost:5000`
   - Network: `http://<your-ip>:5000`

### Access & Authentication

LibreCrawl ships in a self-hosted admin mode. On startup the backend ensures an admin account exists (configure it via `ADMIN_USERNAME`, `ADMIN_EMAIL`, and optional `ADMIN_PASSWORD`), automatically authenticates every browser session with that account, and removes the login/register UI entirely. Protect the crawler behind your trusted network perimeter (VPN, reverse proxy, etc.) because in-app authentication is disabled.

- Set `APP_PORT` to change the listening port (defaults to `5000` when running locally; the Docker examples map it to `5050`).
- The legacy `--local` flag remains for compatibility but behaves the same as the default mode and simply prints the legacy notice.

## Docker & Containerization

### Build and Run with Docker
1. Build the image (runs Playwright install for JS rendering support):
   ```bash
   docker build -t librecrawl .
   ```
2. Run it on port 5050 (to avoid macOS Control Center conflicts), providing a non-default secret key and persisting the SQLite DB:
   ```bash
   docker run -p 5050:5050 \
     -e APP_SECRET_KEY=super-secret \
     -e APP_PORT=5050 \
     -v librecrawl-data:/data \
     librecrawl
   ```
   Optionally add `-e ADMIN_USERNAME=ops-admin -e ADMIN_EMAIL=ops@example.com -e ADMIN_PASSWORD=$(openssl rand -base64 24)` to control the auto-created admin record.
   The image defaults `APP_PORT` and `AUTH_DB_PATH` to `/data/users.db`, so mounting `/data` keeps users and settings across restarts.

### Run Published Image (No Source Checkout)
If you only need the packaged app, pull the image from GitHub Container Registry:
```bash
docker pull ghcr.io/iongpt/librecrawl:latest
docker run -p 5050:5050 \
  -e APP_SECRET_KEY=super-secret \
  -e APP_PORT=5050 \
  -v librecrawl-data:/data \
  ghcr.io/iongpt/librecrawl:latest
```
Use a durable secret (never the default), keep `/data` mounted so `users.db` survives upgrades, and pass the same optional `ADMIN_*` environment variables if you want a custom admin identity stored in the database.

### Develop with Docker Compose
Use the included `docker-compose.yml` for a local-friendly stack (runs in `--local` mode automatically):
```bash
APP_SECRET_KEY=dev-secret APP_PORT=5050 docker compose up --build
```
This maps port `5050`, stores the SQLite database in the named `librecrawl-data` volume, and hot-rebuilds when code changes.

### Deploy with Docker Compose (Prebuilt Image)
To install without cloning, fetch the release compose file and launch the published image:
```bash
curl -fsSL -o docker-compose.yml \
  https://raw.githubusercontent.com/iongpt/LibreCrawl/main/docker-compose.release.yml
APP_SECRET_KEY=prod-secret APP_PORT=5050 ADMIN_USERNAME=ops ADMIN_EMAIL=ops@example.com docker compose up -d
```
The compose file references `ghcr.io/iongpt/librecrawl:latest`, binds `APP_PORT` automatically, and stores the SQLite DB in the `librecrawl-data` volume. Update the `curl` URL if you target a different branch or tag.

### Automated Image Releases
Pushing a semantic tag matching `v*` (for example `v1.0.0`) triggers `.github/workflows/release.yml`, which builds `Dockerfile` and publishes images to `ghcr.io/<owner>/<repo>` tagged with both the version and `latest`. After merging changes, create and push your first release tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```
GitHub Actions will handle the rest.

## Configuration

Click "Settings" to configure:

- **Crawler settings**: depth (up to 5M URLs), delays, external links
- **Request settings**: user agent, timeouts, proxy, robots.txt
- **JavaScript rendering**: browser engine, wait times, viewport size
- **Filters**: file types and URL patterns to include/exclude
- **Export options**: formats and fields to export
- **Custom CSS**: personalize the UI appearance with custom styles
- **Issue exclusion**: patterns to exclude from SEO issue detection

For PageSpeed analysis, add a Google API key in Settings > Requests for higher rate limits (25k/day vs limited).

## Export formats

- **CSV**: Spreadsheet-friendly format
- **JSON**: Structured data with all details
- **XML**: Markup format for other tools

## Multi-tenancy

LibreCrawl supports multiple concurrent users with isolated sessions:

- Each browser session gets its own crawler instance and data
- Settings are stored in browser localStorage (persistent across restarts)
- Custom CSS themes are per-browser
- Sessions expire after 1 hour of inactivity
- Crawl data is isolated between users

## Known limitations

- PageSpeed API has rate limits (works better with API key)
- Large sites may take time to crawl completely
- JavaScript rendering is slower than HTTP-only crawling
- Settings stored in localStorage (cleared if browser data is cleared)

## Files

- `main.py` - Main application and Flask server
- `src/crawler.py` - Core crawling engine
- `src/settings_manager.py` - Configuration management
- `docker-compose.release.yml` - pull-and-run definition for the published GHCR image
- `web/` - Frontend interface files

## License

MIT License - see LICENSE file for details.
