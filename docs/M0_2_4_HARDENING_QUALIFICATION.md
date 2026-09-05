# M0.2.4 — Container hardening qualification

## Goal

Qualify the supported deployment profile under practical container hardening controls without requiring Discord connectivity.

## Default hardening profile

Both Docker Compose and Podman Quadlet now define the same baseline controls:

- non-root image user `1000:1000`;
- all Linux capabilities dropped;
- `no-new-privileges` enabled;
- read-only container root filesystem;
- `/tmp` provided as a bounded tmpfs with `noexec`, `nosuid`, and `nodev`;
- persistent application state writable only through `/data`.

The image itself continues to declare `/data` as its persistent volume. Runtime temporary state such as the healthcheck PID file is written under `/tmp`.

## Qualification gate

`tests/hardening-qualification.sh` starts the candidate image through its normal `tini -> entrypoint -> command` chain with:

```text
--read-only
--tmpfs /tmp:rw,noexec,nosuid,nodev,size=16m
--cap-drop ALL
--security-opt no-new-privileges:true
```

The test verifies:

1. runtime UID/GID are `1000:1000`;
2. `/data` remains writable;
3. the read-only root filesystem rejects writes outside the persistent/runtime paths;
4. the healthcheck remains functional;
5. Docker reports the expected read-only, capability-drop, and no-new-privileges configuration;
6. SIGTERM through the normal init chain produces a clean exit.

The normal `Container` GitHub Actions workflow runs this gate after the existing runtime and upgrade qualification tests.

## Scope limits

M0.2.4 does not claim exhaustive kernel sandboxing or policy-engine qualification. In particular it does not add a custom seccomp or AppArmor/SELinux profile, and the GitHub-hosted test runner is Docker-based rather than a native rootless Podman runtime.

Those may be added as later platform-specific hardening layers without weakening this baseline.

## Pass criterion

M0.2.4 is complete when the normal `Container` workflow succeeds with the hardening gate and the hardened default Compose/Quadlet profiles in place.
