# Elias-1848 OpenShift Deployment - Checkpoint

## Current Status
- ✅ Docker image builds successfully with app-only (no MariaDB)
- ✅ Code pushed to GitHub
- ✅ OpenShift deployment created
- ❌ Database connection failing - firewall/network issue

## What Works
1. **Docker Image**: Successfully builds `elias-1848:latest` from `Dockerfile` (app-only version without MariaDB)
2. **App Running**: Gunicorn starts successfully on port 8080 in the container
3. **OpenShift Build**: Builds from GitHub using the app-only Dockerfile
4. **Routing**: Service and Route created, accessible at `web2-elias-1848.2.rahtiapp.fi`

## Issues Encountered

### 1. Database Connection - FAILED
**Problem**: Cannot connect to Pukki database from OpenShift pods

**Attempted Solutions**:
- Used private IP (192.168.216.202) - Timed out
- Used public IP (86.50.253.238) - Timed out  
- Firewall whitelisted specific host IPs (192.168.2.192, 192.168.3.62) - Pods moved between nodes, IP changed
- OpenShift pod IPs change when pods restart/migrate between nodes

**Root Cause**: 
- Database firewall only allows specific IPs
- OpenShift cluster IPs are dynamic
- Neither private nor public database IPs are reachable from OpenShift pods

### 2. Non-root Container - FIXED
- Added `git` package to Dockerfile
- Changed port from 8000 to 8080 for non-root compatibility  
- Added `PYTHONPATH=/app/runoregi` for module imports
- Changed CMD to use shell form for environment variable expansion

### 3. Secret Management - Working
- Secret `elias` created with database credentials
- Environment variables correctly injected into pods

## Files Changed
- `Dockerfile` - App-only version (renamed from Dockerfile.app)
- `Dockerfile.old` - Original with MariaDB (kept for reference)

## Next Steps (When Network Issue is Resolved)
1. Update secret with correct DB_HOST when solution is found
2. Ensure database credentials are correct
3. Test connection and verify app works

## Potential Solutions to Explore
1. **Ask CSC for OpenShift IP range** - Whitelist entire cluster pod network
2. **Use internal load balancer** - CSC to create internal endpoint
3. **VPN solution** - Connect OpenShift to database network via VPN
4. **Database in OpenShift** - Host MariaDB in same OpenShift project

## Current Secret Configuration
```
DB_HOST=86.50.253.238 (needs update when solution found)
DB_PORT=3306
DB_USER=Elias-1848  
DB_NAME=elias
DB_PASS=<password>
```
