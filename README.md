# mqtt-pwn
mqtt-pwn packaged for RALOS

## Build instructions

On a Ubuntu container run `src/build.sh`.

## Patch note

- Usage of PostGreSQL has been patched away in file `mqtt_pwn/database.py`. Instead it will use an sqlite in memory database.
- `BASE_PATH` has been changed to the installation directory location in `mqtt_pwn/config.py`.

The above patches are done at build time using sed.