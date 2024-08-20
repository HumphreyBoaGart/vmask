# vmask
**vmask** is a shell script utility for deploying and managing sockpuppets, which we will also refer to here as ***masks***.

Using Docker, each mask is set up with its own dedicated web browser and VPN profile. This lets you easily set aside compartmentalized environments for each of your sockpuppets, ensuring that no two sockpuppets connect to the internet from the same IP address.

The web browser is [linuxserver.io's Firefox image](https://docs.linuxserver.io/images/docker-firefox/), which is encased in KasmVNC and accessed via the desired port on any other web browser. This means you can store all your masks in the cloud, on any server or VPS that has Docker installed. *(Direct X11/Wayland access not available. I am working on a companion script with a different browser image for that.)*

The VPN connection is configured using [Gluetun](https://github.com/qdm12/gluetun). By default, our configuration uses Wireguard, but all other Gluetun-compatible VPN modes are supported as well. (See: [Configuring Wireguard](#configuring-wireguard) and [Other VPN Options](#other-vpn-options), below.)

## Dependencies
- **bash** (or compatible)
- **sed**
- **Docker**

Docker should ideally be running in [rootless mode](https://docs.docker.com/engine/security/rootless/), since running a web browser as root is a ***very bad idea***.

## Installation
```
cd $HOME/.config
git clone https://github.com/HumphreyBoaGart/vmask
chmod u+rx vmask/vmask.sh
ln -s vmask/vmask.sh $HOME/.local/bin/vmask
```

Make sure your environment's `$HOME` variable is set to your home directory, or you're going to have a hard time with, well, everything. You can check if it is set by running `printenv HOME`.

## Command Reference
The following commands are built into **vmask.sh**:

### List all available masks
```
vmask list
```

### Take a mask out of storage
```
vmask on MASKNAME
```

### Put mask back into storage
```
vmask off MASKNAME
```

### Generate new mask & save to storage
```
vmask new
```

Or, to bypass interactive mode:
```
vmask new MASKNAME PORT
```

New masks are saved in an inactive state by default. To use a freshly-generated mask, you will need to run `vmask on` after running `vmask new`.

#### Note on ports:
Do not put two masks on the same port! If you are only pulling out one mask out of storage at a time, this is not a big deal. HOWEVER, if you are planning on activating multiple masks at once, you will run into problems if more than one mask is configured to use the same port.

### Delete a mask from storage
```
vmask del MASKNAME
```

### Built-in Documentation
```
vmask help
```

(`vmask -h` and `vmask --help` will also work)

## Mask Access
If you are running vmask locally, you can access your mask's browser instance by going to http://localhost:PORTNUMBER, where PORTNUMBER is the port you told vmask to use.

For remote vmask installs, replace localhost with your server's IP address.

**IMPORTANT:** I highly recommend using HTTPS for remote use. (See: [Enabling SSL](#enabling-ssl), below.)

## Configuring Wireguard
Wireguard is only partially configured by default. You will need to edit the following variables on **Lines 13-17** in `compose.yaml` to finish the setup for each mask:
- WIREGUARD_ENDPOINT_IP
- WIREGUARD_ENDPOINT_PORT
- WIREGUARD_PUBLIC_KEY
- WIREGUARD_PRIVATE_KEY
- WIREGUARD_ADDRESSES

You can also set these options in the skel configuration, if you don't mind all your masks using the same VPN. However, that kinda defeats the purpose of this whole script!

Eventually I may add this to the `vmask new` command, but I wanted to leave it flexible enough for end-users to implement all the other VPN options that I personally do not use. (See: [Other VPN Options](#other-vpn-options), below.)

## Customization
The default settings profile for all new masks is stored in `skel/compose.yaml`. When you create a new mask with `vmask new`, it creates a new directory for that mask in `data/`. Then it creates a copy of this file, saves it to that new directory, and populates it with the attibutes you define.

This means there are **two types** of `compose.yaml` files: One for new masks in `skel/`, and another for existing masks in `data/`.

To edit the default profile from which all new masks will be derived, just edit `skel/compose.yaml` with your favorite text editor.

To edit existing profiles on a case-by-case basis, edit `data/MASKNAME/compose.yaml`.

The following customizations can be made to both types of files:

### Other VPN Options
Gluetun supports a myriad of VPN options and providers, all of which can be implemented in `compose.yaml`. For a full list of other VPN options you can implement, see the [Gluetun wiki](https://github.com/qdm12/gluetun-wiki/blob/main/setup/readme.md).

### Enabling SSL
By default, Firefox is accessed via HTTP on a port of your choosing, mapped to port 3000 within the container. However, linuxserver.io provides the option for HTTPS access on internal port 3001, which is **highly recommended** if you are not using this on a local machine.

To use HTTPS, replace '3000' with '3001' on **Line 8** in `compose.yaml`.

## Sockpuppet Methodology
For an analytical rundown of best practices when engaging in sockpuppetry online, read [my guide about Identity Management at the Anonymous Military Insitute](https://bestpoint.institute/diy/identity-management).
