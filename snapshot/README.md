# /snapshot

This folder is for storing (pruned) snapshots of the bitcoin blockchain. If your container does not have an existing blockchain saved, then the script will check this folder for a snapshot that it can use.

You can find snapshots of the blockchain located here:
https://prunednode.today

If you have an existing blockchain, you must either run `docker volume rm bitcoind-alpha-data` to remove the existing data volume, or manually log into the container and remove files located in the `/data/bitcoin` directory.