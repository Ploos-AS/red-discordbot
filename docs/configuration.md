# Configuration

| Variable | Default | Requirement and behavior |
|---|---|---|
| `INSTANCE_NAME` | `docker` | Optional; unset/empty uses the default. Otherwise letters, digits, `_`, and `-` only; invalid names exit 64. |
| `PREFIX` | `!` | Optional; unset/empty uses the default and configures one prefix. |
| `TOKEN_FILE` | unset | Preferred secret; readable and non-empty file, overrides `TOKEN`. |
| `TOKEN` | unset | Convenience value used only when `TOKEN_FILE` is unset; required for normal startup. |
| `STORAGE_TYPE` | `JSON` | Case-insensitive JSON is the qualified backend; other values exit 64. |
| `EXTRA_ARGS` | empty | Optional Red arguments parsed with Python `shlex`; no shell `eval`. |

Either `TOKEN_FILE` or `TOKEN` is required for normal startup. An unreadable or
empty `TOKEN_FILE` is an error even when `TOKEN` is also set; this preserves
deterministic file precedence. Neither value is printed. Quoted `EXTRA_ARGS`
values remain one argument, shell metacharacters are not executed, and malformed
quoting fails startup explicitly. Example: `EXTRA_ARGS='--owner 123456789 --no-cogs'`. Compose mounts
`./secrets/discord_token` as a secret by default. Restrict that file to its owner
and never add it to source control.
