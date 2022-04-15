# bitcoind-alpine

A simple, light-weight bitcoin daemon using Docker and Alpine Linux.

## How to use

*Make sure that docker is installed, and you are part of docker group.*

```
git clone *this repository url*
cd bitcoind-alpine
./start.sh
```
### /build

The start script will begin with building the bitcoin-core binaries, using the script and Dockerfile located in the `/build` folder.

You may want to adjust the environment variables located at the head of `build/build.sh`. By default, they are set to build version 22 of bitcoin-core, for a linux-x64 based platform. You can see other build options here:

https://github.com/bitcoin/bitcoin/tree/master/depends

When complete, the build script will publish the binary package in the `build/out` folder, and the start script will use this binary going forward.

### /config

Every time the main docker image is rebuilt, these config files will be copied over. If you want to modify the existing configuration, simply run `./start.sh --rebuild` to update your container with the latest changes.

### /snapshot

This folder is for storing (pruned) snapshots of the bitcoin blockchain. If your container does not have an existing blockchain saved, then the script will check this folder for a snapshot that it can use.

You can find snapshots of the blockchain located here:
https://prunednode.today

If you have an existing blockchain, you must remove it first before using a snapshot archive. You can perform this by running `docker volume rm bitcoind-alpha-data` to remove the existing data volume, or `docker exec -it bitcoind-alpine` to gain shell access (then remove all files located in the `/data/bitcoin` directory).

### /scripts

These scripts are copied into the `/root` folder when the docker image is built. Feel free to modify these existing scripts, or add your own!

## Development

The `start.sh` script includes a `DEVMODE` environment flag. Enable this flag in order to skip the default entrypoint, and instead mount the container in ash console.

## Contribution

All contributions are welcome! If you have any questions, feel free to send me a message or submit an issue.

## Resources

Bitcoin Core Config Generator:
https://jlopp.github.io/bitcoin-core-config-generator

