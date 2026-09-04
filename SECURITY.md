# Security policy

Security fixes are provided for the latest released container series and `main`;
older image tags may remain available but are not supported. Report suspected
vulnerabilities privately through GitHub Security Advisories for this repository,
not a public issue. Upstream Red vulnerabilities should also follow upstream's
security policy.

Never commit Discord bot tokens. Prefer `TOKEN_FILE` backed by a container secret,
do not commit a secret-bearing `.env`, restrict host-file permissions, rotate a
token immediately if exposed, keep `/data` backups protected, and pin deployed
production images by digest where practical.

The image runs non-root and requires neither privileged mode nor additional
capabilities. Dependency and security updates are delivered through new immutable
image releases; Red is never upgraded during container startup.
