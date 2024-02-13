# website

endatabas.com

## Setup

```
sudo apt install bibtex2html m4 python
```

## Build

Only builds the bibliography for now. Requires `bibtex2html` and `m4`.

```sh
./bin/build.sh
```

## Run

Test on a local webserver. Requires `python3`.

```sh
./bin/run.sh
```

## WASM Console

Run `make docker-wasm` in the main repo and then copy the resulting files out of the container:

```sh
docker run --rm --entrypoint bash -v "$PWD"/docs/console:/root/www -it endatabas/endb-wasm:latest -c 'cp /root/endb/target/endb* /root/www'
```

## Copyright and License

Copyright 2022-2024 Håkan Råberg and Steven Deobald.

Licensed under the GNU Affero General Public License v3.0.

## Other Licenses

The contents of directories containing license files
(named `LICENSE`, `LICENSE.txt`, `OFL`, or `OFL.txt`)
are licensed accordingly.
