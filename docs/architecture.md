# Architecture

Red 3.5.24 and its Python environment are installed into `/opt/redbot/venv` at
build time. Runtime mutation is confined to `/data`; replacing an image therefore
changes application code without replacing user state. The fixed `redbot` user is
UID/GID 1000 and owns the image-created data directory.

The entrypoint validates configuration, invokes the idempotent bootstrap helper,
reads the token, and `exec`s Red beneath `tini`. Tini forwards signals and reaps
children; Red remains the application process and receives SIGTERM for graceful
shutdown. No supervisor or privilege transition is required.

Health is deliberately local: the entrypoint records the PID that becomes Red,
the instance config must exist, and that exact PID must remain a Red process. Discord outages do
not make the container unhealthy. Metrics, external readiness, PostgreSQL,
Dashboard, audio services, cog provisioning, backups, and multi-instance
orchestration remain future extension points.
