#!/bin/bash -e
# =====================================================================
# Build script running OpenNMS in Docker environment
#
# Source: https://github.com/indigo423/docker-opennms
# Web: https://www.opennms.org
#
# =====================================================================

OPENNMS_DATA_DIR=/opennms-data
OPENNMS_HOME=/opt/opennms

OPENNMS_DATASOURCES_TPL=/root/opennms-datasources.xml.tpl
OPENNMS_DATASOURCES_CFG=${OPENNMS_HOME}/etc/opennms-datasources.xml
OPENNMS_OVERLAY_CFG=/opt/opennms-etc-overlay

OPENNMS_KARAF_TPL=/root/org.apache.karaf.shell.cfg.tpl
OPENNMS_KARAF_CFG=${OPENNMS_HOME}/etc/org.apache.karaf.shell.cfg
OPENNMS_KARAF_SSH_HOST=0.0.0.0
OPENNMS_KARAF_SSH_PORT=8101

OPENNMS_UPDATE_GUARD=${OPENNMS_HOME}/etc/configured
ENFORCE_UPDATE=${OPENNMS_OVERLAY_CFG}/do-upgrade

# Error codes
E_ILLEGAL_ARGS=126
E_DATABASE_UNAVAILABLE=127

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Docker entry script for OpenNMS Horizon service container"
  echo ""
  echo "Overlay Config file:"
  echo "If you want to overwrite the default configuration with your custom config, you can use an overlay config"
  echo "folder in which needs to be mounted to ${OPENNMS_OVERLAY_CFG}."
  echo "Every file in this folder is overwriting the default configuration file in ${OPENNMS_HOME}/etc."
  echo ""
  echo "To enforce database schema and configuration updates, create a file ${OPENNMS_OVERLAY_CFG}/do-upgrade."
  echo ""
  echo "Note: If you run in a service stack with PostgreSQL use a service condition healthy to ensure the database is reachable."
  echo "-f: Start OpenNMS Horizon in foreground with applied overlay configuration."
  echo "-h: Show this help."
  echo "-i: Initialize Java environment, if necessary initialize/update database and apply overlay configuration and do *NOT* start OpenNMS Horizon."
  echo "-s: Same as -i but start OpenNMS Horizon in foreground, this should be the default."
  echo ""
}

# Initialize Java and startup configuration for Karaf
initStartupConfig() {
  if [ ! -d ${OPENNMS_HOME} ]; then
    echo "OpenNMS home directory ${OPENNMS_HOME} doesn't exist."
    exit ${E_ILLEGAL_ARGS}
  fi

  echo -n "Initialize configuration to access database: "
  envsubst < ${OPENNMS_DATASOURCES_TPL} > ${OPENNMS_DATASOURCES_CFG}
  echo "${POSTGRES_HOST}:${POSTGRES_PORT}, OpenNMS User: ${OPENNMS_DBUSER}, Postgres User: ${POSTGRES_USER}"

  echo -n "Initialize Karaf Shell listen port:"
  envsubst < ${OPENNMS_KARAF_TPL} > ${OPENNMS_KARAF_CFG}
  echo "${OPENNMS_KARAF_SSH_HOST}:${OPENNMS_KARAF_SSH_PORT}"

  echo -n "Initialize Java Runtime Environment: "
  ${OPENNMS_HOME}/bin/runjava -s
  echo "$(cat ${OPENNMS_HOME/etc/java.conf})"
}

initOrUpdateDb() {
  if [ ! -f ${OPENNMS_UPDATE_GUARD} ]; then
    echo "Initialize or update database schema."
    ${OPENNMS_HOME}/bin/install -dis
  else
    echo "Database is configured skip initOrUpdateDb."
  fi
}

applyOverlayConfig() {
  if [ "$(ls -A ${OPENNMS_OVERLAY_CFG})" ]; then
    echo "Apply custom configuration from ${OPENNMS_OVERLAY_CFG}."
    cp -r ${OPENNMS_OVERLAY_CFG}/* ${OPENNMS_HOME}/etc
  else
    echo "No custom config found in ${OPENNMS_OVERLAY_CFG}. Use default configuration."
  fi

  if [ -f ${ENFORCE_UPDATE} ]; then
    echo "Enforce update and delete existing guard file."
    rm -f ${OPENNMS_HOME}/etc/configured
  fi
}

# Start opennms in foreground
start() {
  cd ${OPENNMS_HOME}/bin
  exec ./opennms -f start
}

# Evaluate arguments for build script.
if [[ "${#}" == 0 ]]; then
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Evaluate arguments for build script.
while getopts fhis flag; do
  case ${flag} in
    f)
      applyOverlayConfig
      start
      exit
      ;;
    s)
      initStartupConfig
      applyOverlayConfig
      initOrUpdateDb
      start
      exit
      ;;
    h)
      usage
      exit
      ;;
    i)
      initStartupConfig
      applyOverlayConfig
      initOrUpdateDb
      exit
      ;;
    *)
      usage
      exit ${E_ILLEGAL_ARGS}
      ;;
  esac
done

# Strip of all remaining arguments
shift $((OPTIND - 1));

# Check if there are remaining arguments
if [[ "${#}" > 0 ]]; then
  echo "Error: To many arguments: ${*}."
  usage
  exit ${E_ILLEGAL_ARGS}
fi
