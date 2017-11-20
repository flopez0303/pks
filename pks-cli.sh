#!/bin/bash

PKS_API_URL='10.4.2.92'
export runtime_config=$(bosh runtime-config --name ops_manager_dns_runtime)

case $1 in

"--create")
  echo "Creating Cluster with Json Payload ..."
  postData="$(cat <<EOF
    {
    "name": "$2",
    "parameters": {
      "kubernetes_master_host": "10.6.8.11",
      "worker_haproxy_ip_addresses": "10.6.8.12"
      }
    }
EOF
)"
  echo $postData | jq .
  curl -vvv -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json;charset=UTF-8' -d "$postData" https://$PKS_API_URL:9021/v1/clusters
;;
"--list")
  echo "Getting Clusters ..."
  curl -s -k -X GET --header 'Content-Type: application/json' --header 'Accept: application/json;charset=UTF-8' -d "$postData" https://$PKS_API_URL:9021/v1/clusters | jq .
;;
"--bind")
  echo "Binding to Cluster ..."
  curl -k -X POST --header 'Content-type: application/json' https://$PKS_API_URL:9021/v1/clusters/$2/binds | bosh int - --path=/credentials/kubeconfig >> $HOME/.kube/config
;;
"--delete")
  echo "Deleteing Cluster $2 ..."
  curl -k -X DELETE --header 'Content-Type: application/json' --header 'Accept: application/json;charset=UTF-8' https://$PKS_API_URL:9021/v1/clusters/$2
;;
"--help")
  echo "MGs simple script"
  echo "  --create [name] ... creates a cluster"
  echo "  --list ... list all clusters"
  echo "  --bind [name] ... get a clusters kubeconfig"
  echo "  --delete [name] ... deletes a cluster"
;;
*)
  echo "Curl Function $1 unknown"
;;
esac
