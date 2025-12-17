# AI Coding Guidelines for Internet Billing RADIUS System

## Architecture Overview
This is a Next.js 15 full-stack application for managing internet billing with RADIUS integration. The app uses the App Router with nested API routes. Key components:
- **Database Layer**: MariaDB with connection pooling via `mysql2` (see `scripts/app/lib/db.js`)
- **Authentication**: JWT-based auth with bcrypt password hashing (see `scripts/app/lib/app/lib/auth.js`)
- **API Structure**: RESTful endpoints under `/api/` with consistent response format: `{success: true, data: ...}` or `{error: "..."}`
- **Frontend**: React client components with Tailwind CSS and Lucide icons
- **Deployment**: PM2 process manager for production clustering

## Key Patterns & Conventions
- **Database Queries**: Use parameterized queries via `query(sql, params)` from `db.js` to prevent SQL injection
- **API Routes**: Handle errors with try/catch, return JSON responses with appropriate HTTP status codes (e.g., `scripts/app/lib/app/lib/app/login/app/api/auth/login/route.js`)
- **Authentication**: Protect routes with JWT verification; user roles include 'admin' and 'operator'
- **Data Flow**: Client fetches from API endpoints (e.g., dashboard stats from `/api/dashboard/stats`)
- **Imports**: Use `@/` alias for absolute imports (configured in Next.js)
- **Environment**: Store secrets in `.env.local` (DB credentials, JWT_SECRET)

## Database Schema Essentials
- `users`: Admin/operator accounts with roles
- `customers`: Subscriber data with RADIUS credentials (username/password)
- `packages`: Internet plans with speed/price/validity
- `payments`: Billing records with invoice numbers
- `radius_logs`: Session tracking for bandwidth usage

## Development Workflow
- **Setup**: Run `setup.sh` for Ubuntu environment, then `npm install`
- **Database**: Import `scripts/database.sql` after configuring MariaDB
- **Development**: `npm run dev` for hot-reload
- **Build**: `npm run build` then `npm run pm2:start` for production
- **Debugging**: Check PM2 logs in `logs/` directory; use browser dev tools for client-side issues

## Common Tasks
- **Add API Endpoint**: Create `route.js` in appropriate `/api/` subdirectory with GET/POST handlers
- **Database Migration**: Update `database.sql` and run import manually
- **UI Components**: Use Tailwind classes; import icons from `lucide-react`
- **Authentication Check**: Verify JWT token in middleware before accessing protected routes

## Integration Points
- **RADIUS Sync**: Customer credentials auto-sync for network authentication
- **Payment Processing**: Support cash/transfer/QRIS methods
- **Reports**: Export functionality for customer/payment data
- **Real-time Dashboard**: Stats update via API polling

Reference: `README.md` for full setup; `package.json` for scripts; `pm2.config.js` for deployment config.</content>
<parameter name="filePath">c:\Users\diran\OneDrive\Documents\GitHub\internet-billing-radius\.github\copilot-instructions.md