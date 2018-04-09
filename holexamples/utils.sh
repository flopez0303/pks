#!/bin/bash

# NSX client that talks to the manager
pks::nsx::client() {
  method=${1}
  api='api/v1/'${2}
  payload=${3}

  case $method in
  "get"*)
    http --verify=no -a ${NSX_MANAGER_USERNAME}:${NSX_MANAGER_PASSWORD} GET https://${NSX_MANAGER_IP}/$api ${payload}
    ;;
  "post"*)
    echo "${payload}" | http --verify no -a ${NSX_MANAGER_USERNAME}:${NSX_MANAGER_PASSWORD} POST https://${NSX_MANAGER_IP}/$api
    ;;
  "put"*)
    echo "${payload}" | http --verify=no -a ${NSX_MANAGER_USERNAME}:${NSX_MANAGER_PASSWORD} PUT https://${NSX_MANAGER_IP}/$api
    ;;
  "delete"*)
    http --verify=no -a ${NSX_MANAGER_USERNAME}:${NSX_MANAGER_PASSWORD} DELETE https://${NSX_MANAGER_IP}/$api
    ;;
  *)
    echo "Unrecognized method: ${method}"
    ;;
  esac
}

getid() {
  jq '.id' -cr
}
