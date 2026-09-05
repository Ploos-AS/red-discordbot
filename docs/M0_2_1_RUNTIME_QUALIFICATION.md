# M0.2.1 Runtime qualification

M0.2.1 turns the existing container smoke coverage into an explicit lifecycle qualification gate.

## Automated gate

`tests/runtime-qualification.sh` is run by the normal container CI job against the locally built amd64 image.

It verifies:

- a fresh named `/data` volume can be bootstrapped as the image's default non-root user;
- bootstrap is idempotent and does not rewrite the Red instance configuration;
- a token supplied through `TOKEN_FILE` is not emitted in container logs when Red exits during the deliberately offline startup probe;
- the image healthcheck observes the expected `redbot` PID/liveness contract;
- SIGTERM through `docker stop` produces a clean exit;
- the same container can be restarted after a clean stop;
- persistent data survives the stop/start cycle.

The lifecycle portion deliberately uses a local helper process named `redbot`. It tests the container's PID, healthcheck, signal and persistence contracts without making a Discord connection and without requiring a live Discord credential in CI.

## Existing complementary coverage

The pre-existing smoke/container tests continue to verify the pinned Red version, non-root `/data` writes, bootstrap behavior, token-file error handling, token non-disclosure, healthcheck behavior and clean stop semantics.

## Not qualified by M0.2.1

M0.2.1 does **not** claim:

- successful authentication or connectivity to Discord;
- application-level Discord behavior after login;
- rootless Podman runtime qualification;
- native arm64 runtime execution (the release workflow still builds and publishes arm64);
- upgrade/rollback compatibility between two different container releases;
- backup/restore qualification.

Those require separate gates rather than being inferred from build success.

## Pass criterion

M0.2.1 is qualified for a commit when the normal `Container` workflow succeeds, including `tests/runtime-qualification.sh`. A checked-in test definition alone is not evidence that a particular commit passed GitHub Actions.
