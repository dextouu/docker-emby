# Emby Image

## Description
What is [Emby](https://github.com/MediaBrowser/Emby) ?

Emby Server is a home media server built on top of other popular open source technologies such as Service Stack, jQuery, jQuery mobile, and Mono.

It features a REST-based API with built-in documention to facilitate client development. We also have client libraries for our API to enable rapid development. 

**This image not contain root process**

## Configuration
### Environments
* UID : Choose uid for launch emby (default : 991)
* GID : Choose gid for launch emby (default : 991)

### Volumes
* /embyData : Configurations files are here

### Ports
* 8096

## Usage
### Speed launch
```shell
docker run -d -p 8096 dextou/emby
```
URI access : http://XX.XX.XX.XX:8096

### Advanced launch
```shell
docker run -d -p 8096 \
	-v /docker/config/emby:/embyData \
	-v /docker/Media:/Media \
	-e UID=1001 \
	-e GID=1001 \
	dextou/emby
```
URI access : http://XX.XX.XX.XX:8096


