# Migration

Stop the old bot and take a verified backup before migration. Identify its Red
instance configuration, data path, storage backend, installed repositories, and
UID/GID. This image expects JSON state under `/data/redbot` and its Red instance
registry under `/data/.config/Red-DiscordBot`.

Paths used by other images, including PhasecoreX variants, have not been verified
as directly compatible. Do not mount an entire old application directory over
`/data` blindly. Prefer Red's own backup/restore facilities or copy a confirmed
Red data directory into a disposable volume, then inspect and test it with the
same upstream Red version. Never copy a source container's Python environment or
application installation into `/data`; make copied state writable by UID/GID
1000 and validate with `edge` or the intended stable tag. PostgreSQL migrations
are outside v0.1.0. Keep the source backup unchanged until commands, cogs, and
data have been verified.
