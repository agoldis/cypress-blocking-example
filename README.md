# Cypress v13 Blocking

Build the docker image:

```sh
 docker build -t cypress-blocking-example .
```

## NPM Dependencies Blocking

Start an interactive shell:

```sh
docker run -it --entrypoint /bin/bash cypress-blocking-example

# from within docker
npm i
Xvfb :99 &
export DISPLAY=:99

# Run cypress in standalone mode - note that no dependencies were install - it's a bare cypress project
# Stop the runner after it starts running the tests - we don't need the whole output
strace -o /tmp/strace -s 2024 -f /root/.cache/Cypress/13.3.0/Cypress/Cypress --no-sandbox -- --run-project /app --cwd /app --userNodePath /usr/local/bin/node --userNodeVersion 20.6.1

# Examie the syscalls
cat /tmp/strace | grep statx  | grep -v 13.3.0 | egrep "cypress-|currents" --color
```

Running this command reveals what packages are being scanned. Note: those packages are not even installed at this point.

```plain
243   statx(AT_FDCWD, "/app/node_modules/cypress-plugin-retries", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/node_modules/cypress-plugin-retries", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/root/.node_modules/cypress-plugin-retries", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/root/.node_libraries/cypress-plugin-retries", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/cypress-cloud/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/cypress-debugger/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/@currents/cypress-debugger-plugin/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/@currents/cypress-debugger-support/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL, 0xffffef5c5240) = -1 ENOENT (No such file or directory)
243   statx(AT_FDCWD, "/app/node_modules/cypress-vscode/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/cypress-debug/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL, 0xffffef5c5240) = -1 ENOENT (No such file or directory)
243   statx(AT_FDCWD, "/app/node_modules/@deploysentinel/cypress-debugger/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
243   statx(AT_FDCWD, "/app/node_modules/@deploysentinel/cypress-parallel/package.json", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
271   statx(AT_FDCWD, "/app/currents.config.*", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
302   statx(AT_FDCWD, "/tmp/cypress-0", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
330   statx(AT_FDCWD, "/tmp/cypress-0", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
336   statx(AT_FDCWD, "/tmp/cypress-0", AT_STATX_SYNC_AS_STAT, STATX_ALL,  <unfinished ...>
```

Installing one of the packages would trigger the blocking:

```sh
npm i cypress-cloud
/root/.cache/Cypress/13.3.0/Cypress/Cypress --no-sandbox -- --run-project /app --cwd /app --userNodePath /usr/local/bin/node --userNodeVersion 20.6.1

# We've detected that you're using a 3rd party library that is not supported by Cypress: cypress-cloud
# To continue running Cypress, please remove this library or reach out for help migrating.
# https://on.cypress.io/unsupported-third-party-library?p=w53Ds8Oqw6zDn8Otw63Cp8Odw6bDqcOvw57CusKrwqjCs8KowrA%3D
```

## Filesystem Dependencies Blocking

```sh
# Make sure to remove previosly installed packages
npm remove cypress-cloud

# Create a fake local package
mkdir -p ./node_modules/foobar
vim ./node_modules/foobar/package.json
```

Add the following content:

```json
{
  "name": "foobar",
  "author": "Currents Software Inc"
}
```

Now, modify the root `./package.json`:

```js
{
    // ...
    "dependencies": {
        "foobar": "file://node_modules/foobar",
        "cypress": "^13.3.0"
    }
}
```

Run Cypress again:

```sh
/root/.cache/Cypress/13.3.0/Cypress/Cypress --no-sandbox -- --run-project /app --cwd /app --userNodePath /usr/local/bin/node --userNodeVersion 20.6.1


# We've detected that you're using a 3rd party library that is not supported by Cypress: foobar
# To continue running Cypress, please remove this library or reach out for help migrating.
# https://on.cypress.io/unsupported-third-party-library?p=w6DDqcOpw5zDm8Os

```
