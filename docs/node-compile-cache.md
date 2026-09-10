# Shipping node's compile cache in the image

An unfinished speedup for the nine LTF images built on `javascript-node`.
Measured and working; not adopted, because the gain did not justify the number
of repos it touches. Everything below is a measurement, not a plan.

## The idea

Node writes compiled bytecode to disk when `NODE_COMPILE_CACHE` names a
directory, and reads it back instead of compiling again. A kata gets a fresh
container per test-run, so a cache written during a run is thrown away with the
container. Warming one at image-build time is what lets a run read it.

This is the same shape as the mypy cache in the python LTFs; see
`warm_mypy_cache.sh` in cyber-dojo-languages/python-pytest.

## What it is worth

Measured on javascript-assert-jquery, whose `require('jsdom')` costs 0.226s of
its 0.269s node step. One run per fresh container, alternating between the two
images so drift could not favour either:

| run | unmodified | warmed cache |
|-----|------------|--------------|
| 1   | 0.313s     | 0.265s       |
| 2   | 0.296s     | 0.244s       |
| 3   | 0.290s     | 0.238s       |
| 4   | 0.286s     | 0.240s       |

0.05s, about 17% of the node step. The cache is 6.5MB across 1129 files.

That 0.05s was measured on one LTF only. javascript-assert loads almost nothing
and would gain less; the jest ones might gain more. Nobody has measured them.

## The trap: node partitions the cache by user id

A cache warmed as root is in a directory the sandbox user cannot read:

    /node-compile-cache/v25.8.1-arm64-392347a2-0        warmed as root
    /node-compile-cache/v25.8.1-arm64-392347a2-41966    written by the kata

The trailing number is the uid. Warming as root leaves a kata recompiling
everything and then writing a second full copy, so the image carries 6.5MB it
never reads and every run pays to write another. That measured 0.340s against
0.270s unmodified: enabling the cache wrongly is slower than not having it.

Warm as `sandbox` and the run hits it on its first and only run.

`chmod -R 777` on the cache directory does not help, and is what makes this
worth writing down: the python mypy cache gets away with warming as root
because mypy keys its cache on the python version alone
(`/mypy-cache/3.14`, one directory shared by every user). That was verified
still working as the sandbox user, 0.119s warm against 0.412s cold.

## What adopting it would take

1. `ENV NODE_COMPILE_CACHE=/node-compile-cache` in this repo's
   `docker/Dockerfile.base`. An `ENV` is inherited, so all nine LTF images get
   it without touching nine `cyber-dojo.sh` files.
2. A `warm_node_compile_cache.sh` per LTF image repo, run after that repo
   installs its own packages, since the cache only helps for modules actually
   loaded during warming. The nine are the seven `javascript-*`, plus
   `typescript-jest` and `rescript-jest`.
3. Two assertions in each warm script, either of which catches the uid trap:
   - the baked directory name ends in the sandbox uid;
   - a warm run beats a cold one, timed **as sandbox** rather than as root.
4. Nine `image_name` sha bumps in the start-point manifests once the images
   publish.

## Things already tried that do not work

- Warming from a different directory than the kata uses. Node keys on the uid,
  not on the path; warming from `/etc/jquery` and from `/sandbox` measured the
  same.
- Shaping the warm script like the kata, building a `JSDOM` rather than a bare
  `require`. No better than the bare require.

## How to measure it, if this is picked up again

One run per fresh container, alternating between the images under comparison.
Best-of-N inside a single container measures runs 2..N, which do not exist in
production, and reports a speedup that is not there. That mistake was made
during this work and nearly shipped a slowdown to nine repos.
