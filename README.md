# Waterfall.sh

![License](https://img.shields.io/github/license/astorks/Waterfall.sh?style=for-the-badge)

A single bash script to install/run a Waterfall server.<br />

## Environment Variables & Startup Arguments
| Name                      | Argument | Description | Default Value |
| ------------------------- | -------- | ------------| ------------- |
| WATERFALL_VERSION           | --version [version] | The minecraft version to download the latest Waterfall release. | 1.16 |
| WATERFALL_JAR_NAME          | --jar-name [name] | The name of the Waterfall jar file. | waterfall.jar |
| WATERFALL_START_MEMORY        | --start-memory [memory] | The minimum ammount of memory to allocate to the JVM. | 512M |
| WATERFALL_MAX_MEMORY        | --max-memory [memory] | The maximum ammount of memory to allocate to the JVM. | 512M |
| WATERFALL_SKIP_UPDATE       | --skip-update | Skip Waterfall updates, will still download the latest version if jar file is missing. | N/A |
| AUTO_RESTART              | --auto-restart | Auto-Restart the server unless a Ctrl-C command is issued or the container is stopped | N/A |


## Basic Example
```bash
~$ mkdir waterfall && cd waterfall
~/waterfall$ curl -s -o waterfall.sh https://raw.githubusercontent.com/astorks/Waterfall.sh/master/waterfall.sh
~/waterfall$ chmod +x waterfall.sh
~/waterfall$ ./waterfall.sh --version 1.16 --start-memory 512M --max-memory 512M
```

## Docker Example
```bash
~$ docker run -v waterfall:/var/opt/waterfall -p 25565:25565 -e WATERFALL_VERSION=1.16 -e WATERFALL_START_MEMORY=512M -e WATERFALL_MAX_MEMORY=512M -it astorks/waterfall.sh:latest
```