# Internet Billing Radius System

Full-stack internet billing system with RADIUS integration for Ubuntu 24.xx

## Features

- ✅ User authentication & authorization
- ✅ Customer management
- ✅ Package/plan management
- ✅ Payment processing
- ✅ Invoice generation
- ✅ RADIUS user synchronization
- ✅ Real-time dashboard
- ✅ Responsive UI
- ✅ Export reports (PDF/Excel)

## Tech Stack

- **Frontend**: Next.js 15, React 19, Tailwind CSS
- **Backend**: Next.js API Routes
- **Database**: MariaDB
- **Process Manager**: PM2
- **Authentication**: JWT
- **Charts**: Chart.js

## Installation

### 1. System Requirements
- Ubuntu 24.04 LTS
- Node.js 20.x
- MariaDB 10.x

### 2. Quick Setup
```bash
# Clone repository
git clone <your-repo>
cd internet-billing

# Make setup script executable
chmod +x scripts/setup.sh

# Run setup (requires sudo)
./scripts/setup.sh

# Install Node.js dependencies
npm install

# Setup environment variables
cp .env.example .env.local
# Edit .env.local with your configuration

# Import database schema
mysql -u billing_admin -p billing_radius < scripts/database.sql

# Build and start
npm run build
npm run pm2:start

# Access application
http://localhost:3000