
export BOSH_CLIENT=ops_manager
export BOSH_CLIENT_SECRET=UzO723JHKavNokdZA0MQaW3-IW-I2_N-
bosh login -e kubobosh --client=$BOSH_CLIENT --client-secret=$BOSH_CLIENT_SECRET
 bosh alias-env kubobosh -e 172.31.0.2 --ca-cert /etc/ssl/certs/root_ca_certificate
