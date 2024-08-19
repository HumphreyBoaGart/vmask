# vmask data directory

This is the directory in which `vmask.sh` saves compartmentalized mask configurations and their associated browser data. When you start generating new masks, they will each get their own dedicated subdirectory within this directory.

Each mask subdirectory contains:

### storage/
This is the persistent storage volume for the mask's web browser (bookmarks, sessions, cookies, etc). For more information on how this is implemented, read the docs at [linuxserver.io](https://docs.linuxserver.io/general/running-our-containers/#the-config-volume).

### compose.yaml
This is the Docker file which controls the configuration for the mask. Any fine-tuning you choose to do on a case-by-case basis, is done by editing this file.
