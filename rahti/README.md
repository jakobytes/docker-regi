# Rahti Deployment

Rahti is CSC's OKD 4 / OpenShift 4 platform. Project: **elias-1848**.

## Prerequisites

```bash
# Install the oc CLI, then log in
oc login https://api.2.rahti.csc.fi:6443
oc project elias-1848
```

## First deployment

```bash
rahti/deploy.sh --rebuild
```

This will:
1. Create/replace the `volkslieder-db` Secret from `.env`
2. Apply all manifests (ImageStream, BuildConfig, Deployment, Services, Routes)
3. Upload the local repo as a binary build source and build the image in the cluster
4. The image trigger annotation on the Deployment rolls out the new image automatically

## Updating after code changes

```bash
rahti/deploy.sh --rebuild
```

To apply manifest changes only (no image rebuild):

```bash
rahti/deploy.sh
```

## URLs

| Service | URL |
|---------|-----|
| Runoregi | https://volkslieder-runoregi-elias-1848.2.rahtiapp.fi |
| Shiny | https://volkslieder-shiny-elias-1848.2.rahtiapp.fi |

## Manifest overview

| File | Purpose |
|------|---------|
| `imagestream.yaml` | Stores the built image inside the cluster |
| `buildconfig.yaml` | Binary Docker build — source uploaded via `oc start-build` |
| `deployment.yaml` | Single pod running both Runoregi and Shiny |
| `services.yaml` | ClusterIP services for port 8000 and 3838 |
| `routes.yaml` | HTTPS edge-terminated routes for both services |

---

## Rahti-specific constraints (lessons learned)

### CPU limit/request ratio capped at 5×
Rahti enforces a maximum limit-to-request ratio of 5 per container.
Current values: request `400m`, limit `2000m` (exactly 5×).
Do not lower the request below `limit / 5` or pods will be forbidden.

### Project CPU quota is 4 cores
The elias-1848 project quota is 4 CPU cores total.  
The Deployment uses `strategy: Recreate` so rollouts kill the old pod first —
a rolling update would need headroom for two pods simultaneously and exceeds quota.

### `/var/lib/shiny-server` must be world-writable
Shiny Server creates `bookmarks/` under `/var/lib/shiny-server` on startup.
OpenShift runs containers as a random non-root UID, so the Dockerfile explicitly
creates this directory and sets `chmod a+rwx` on it.

### Gunicorn control socket needs a writable HOME
Gunicorn places its control socket at `$HOME/.gunicorn`.
Under OpenShift's random UID there is no home directory, so `$HOME` defaults to `/`
which is not writable. `start-both.sh` exports `HOME=/tmp` before starting gunicorn.
