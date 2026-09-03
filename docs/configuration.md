# Configuration

| Variable | Default | Meaning |
|---|---|---|
| `INSTANCE_NAME` | `docker` | Red instance name; letters, digits, `_`, and `-` only. |
| `PREFIX` | `!` | One non-empty command prefix. |
| `TOKEN_FILE` | unset | Read the Discord token from this file; preferred and takes precedence. |
| `TOKEN` | unset | Convenience token value used only when `TOKEN_FILE` is unset. |
| `STORAGE_TYPE` | `JSON` | M0 supports and tests JSON only. |
| `EXTRA_ARGS` | empty | Extra Red CLI arguments parsed with Python `shlex`, never shell `eval`. |

Either `TOKEN_FILE` or `TOKEN` is required for normal startup. An unreadable or
empty `TOKEN_FILE` is an error even when `TOKEN` is also set; this preserves
deterministic file precedence. Neither value is printed. Malformed `EXTRA_ARGS`
quoting fails startup explicitly. Example: `EXTRA_ARGS='--owner 123456789 --no-cogs'`. Compose mounts
`./secrets/discord_token` as a secret by default. Restrict that file to its owner
and never add it to source control.
