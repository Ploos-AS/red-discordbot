# Security policy

Security fixes are provided for the latest released container series and `main`;
older image tags may remain available but are not supported. Report suspected
vulnerabilities privately through GitHub Security Advisories for this repository,
not a public issue. Upstream Red vulnerabilities should also follow upstream's
security policy.

Never commit Discord bot tokens. Prefer `TOKEN_FILE` backed by a container secret,
restrict host-file permissions, rotate a token immediately if exposed, keep `/data`
backups protected, and pin deployed production images by digest where practical.
