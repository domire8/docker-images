# docker_images

![Build and Push ROS and ROS2 images](https://github.com/aica-technology/docker-images/actions/workflows/build-push.yml/badge.svg)

## Images

### ROS workspace

The ros_ws image provides a ROS workspace.
Build it by running the [build script](ros_ws/build.sh) while
in the [ros_ws](ros_ws) directory. Modify the ROS distribution in
the script as desired.

The username that should be supplied at login is `ros`.

### ROS2 workspace

Similar to the ROS workspace, the ros2_ws image provides a ROS2 workspace.
Build it by running the [build script](ros2_ws/build.sh) while
in the [ros2_ws](ros2_ws) directory. Modify the ROS2 distribution
in the script as desired.

The username that should be supplied at login is `ros2`.

## Scripts

The provided scripts simplify launching and connecting to docker containers based
on the provided images.

- `aica-docker server`
- `aica-docker connect`
- `aica-docker interactive`

### Installation of `aica-docker`

The [aica-docker.sh script](scripts/aica-docker.sh) is a simple wrapper for all
scripts in this repository, and is designed to be run with the `aica-docker` command.

Install the `aica-docker` command using the [install-aica-docker.sh script](scripts/install-aica-docker.sh).
This will create a symbolic link in `/usr/local/lib` to the scripts in this repository.

```shell
cd scripts
sudo ./install-aica-docker.sh
```

To remove the `aica-docker` symbolic link and command,
simply run the [uninstall-aica-docker.sh script](scripts/install-aica-docker.sh)

```shell
cd scripts
sudo ./uninstall-aica-docker.sh
```

Note: if the path of this repository is ever changed, the symbolic link will fail to find the scripts.
Fix this by uninstalling and then re-installing the link.

### interactive

The [interactive.sh script](scripts/src/interactive.sh) is a wrapper for `docker run`
and starts an interactive container that is removed on exit. It takes a pre-built image
as an argument. Run `aica-docker interactive -h` for more info.

### server

The [server.sh script](scripts/src/server.sh) is a wrapper for `docker run` that is
configured specifically for the images in this repository, which have
a custom `sshd_entrypoint.sh` script built in. It spins up a background container
running an SSH server, authenticated with the host RSA key pair for the specified user.
Run `aica-docker server -h` for more info.

### connect

The [connect.sh script](scripts/src/connect.sh) is a wrapper for `docker exec` that
connects an interactive shell to a running container instance. It sets
the corresponding environment variables for display forwarding.
Run `aica-docker connect -h` for more info.


## Notes on X11 display forwarding for Mac

Initial setup (you will only need to do this once).
```shell script
brew install socat
brew cask install xquartz

open -a XQuartz
```
Allow X11 connections by going to XQuartz->Preferences and enabling
"Allow connections from network clients" in the Security tab.

To start the display server, run the following in a dedicated terminal
```shell script
open -a XQuartz
socat TCP-LISTEN:6000,range=127.0.0.1/32,fork UNIX-CLIENT:\"$DISPLAY\"
```
Now, as long as the docker container has the `DISPLAY` variable set
to `host.docker.internal:0`, any GUIs in the container will be forwarded
by X11 and opened as windows on the host.
