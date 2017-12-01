[![](https://images.microbadger.com/badges/version/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own license badge on microbadger.com")

## Supported tags

* `latest`, daily bleeding edge develop release Horizon 22
* `21.0.1-1`, `stable`, latest stable Horizon 21
* `21.0.0-1`, stable Horizon 21
* `20.1.0-1`, stable Horizon 20
* `20.0.2-1`, stable Horizon 20
* `20.0.1-1`, stable Horizon 20
* `20.0.0-1`, stable Horizon 20
* `19.1.0-1`, stable Horizon 19
* `19.0.1-1`, stable Horizon 19
* `19.0.0-1`, stable Horizon 19
* `18.0.4-1`, stable Horizon 18
* `18.0.3-1`, stable Horizon 18
* `foundation-2017` release candidate 18.0.4 as base for Meridian
* `foundation-2016` release candidate 17.0.1 as base for Meridian

### latest

* CentOS 7 with OpenJDK 8u151-jdk
* Official PostgreSQL 9.6.3
* Horizon daily develop snapshot

### 21.0.1-1

* CentOS 7 with OpenJDK 8u151-jdk
* Official PostgreSQL 9.6.3
* Horizon 21.0.1-1

### 21.0.0-1

* CentOS 7 with OpenJDK 8u151-jdk
* Official PostgreSQL 9.6.3
* Horizon 21.0.0-1

### 20.1.0-1

* CentOS 7 with OpenJDK 8u144-jdk
* Official PostgreSQL 9.6.3
* Horizon 20.1.0-1

### 20.0.2-1

* CentOS 7 with OpenJDK 8u144-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.2-1

### 20.0.1-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.1-1

### 20.0.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.0-1

### 19.1.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.1.0-1

### 19.0.1-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.0.1-1

### 19.0.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.0.0-1

### 18.0.4-1

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 18.0.4-1

### 18.0.3-1

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 18.0.3-1

### foundation-2017

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.6.1
* Horizon 18.0.4

### foundation-2016

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 17.0.1

## Horizon Docker files

This repository provides snapshots for Horizon as docker images.
The image provides the Horizon core monitoring services and the web application.

It is recommended to use `docker-compose` to build a service stack using the official PostgreSQL images.
In case you have already a PostgreSQL database running, you can provide the database configuration in the `.opennms.env` and `.postgres.env` environment files.

In the GitHub repository you'll find a an example docker-compose.yml file which describes a service stack with vanilla PostgreSQL and this container image.
The data for the PostgreSQL database, OpenNMS Horizon RRD data and configuration is persisted using the local storage driver.

## Dealing with Horizon Configuration files

To make configuration more flexible it is possible to provide a etc-overlay directory which overwrites default configuration files with your custom ones.

- ./etc-overlay:/opt/opennms-etc-overlay

Just add the volumes directive in `docker-compose.yml` in the opennms service section:

```
volumes:
    - ./etc-overlay:/opt/opennms-etc-overlay
```

All files in this directory will be used to overwrite the default configuration when you start up the container.

## Requirements

* docker 1.11+
* docker-compose 1.8.0+
* git
* optional on MacOSX or Windows a Docker environment

## Usage

```
git clone https://github.com/opennms-forge/docker-horizon-core-web.git
cd docker-horizon-core-web
docker-compose up -d
```

The web application is exposed on TCP port 8980.
You can login with default user *admin* with password *admin*.
Please change immediately the default password to a secure password.

## Start the OpenNMS Horizon Service

The entry point script is used to control starting behaviour.
You can provide the following arguments in you `docker run` command or in your `docker-compose.yml`.

```
-f: Apply existing overlay configuration and OpenNMS Horizon on foreground.
-i: Initialise startup configuration, database, apply overlay configuration and to database schema update if necessary, do *not* start OpenNMS Horizon.
-s: The same as `-i` but start OpenNMS Horizon afterwards, this should be the default option.
```

## Update OpenNMS Horizon service

OpenNMS Horizon updates can change the database schema or invalidate configuration files.
If you want to enforce a database schema and configuration migration update, place a file "do-upgrade" in your etc-overlay configuration update.
It will ensures the guard file `${OPENNMS_HOME}/etc/configured` gets deleted and the `install -dis` command is enforced to run.

It will migrate your existing database and configuration files or give hints about configuration files which require manual merges.

## Support and Issues

Please open issues in the [GitHub issue](https://github.com/opennms-forge/docker-horizon-core-web) section.

## Author

ronny@opennms.org
