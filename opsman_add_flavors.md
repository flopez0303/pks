Perform the following steps on the Ops Manager VM

#### 1) Login to the Ops Manager VM 
`ssh ubuntu@opsman.lab.local`

#### 2) Set the API target
`uaac target https://localhost/uaa --skip-ssl-validation`\
```
Unknown key: Max-Age = 86400
Target: https://localhost/uaa
```

#### 3) Collect the Admin user token
`uaac token owner get`\
    <p>Client ID: `opsman`\
    Client secret: `###LEAVE BLANK###`\
    User name: `admin`\
    Password: `###PASSWORD USED TO LOGIN TO WEB UI###`</p>
```
Successfully fetched token via owner password grant.
Target: https://localhost/uaa
Context: admin, from client opsman
```

#### 4) Add a new client account
`uaac client add -i`\
    <p>Client ID:  `apiuser`\
    New client secret:  `### For example, VMware1!VMware1! ###`\
    Verify new client secret:  `****************`\
    scope (list):  `opsman.admin`\
    authorized grant types (list):  `client_credentials`\
    authorities (list):  `opsman.admin`\
    access token validity (seconds):  `43200`\
    refresh token validity (seconds):  `43200`\
    redirect uri (list):\
    autoapprove (list):\
    signup redirect url (url):\
    scope: opsman.admin\
    client_id: apiuser\
    resource_ids: none\
    authorized_grant_types: client_credentials\
    autoapprove:\
    access_token_validity: 43200\
    refresh_token_validity: 43200\
    authorities: opsman.admin\
    name: apiuser\
    signup_redirect_url:\
    required_user_groups:\
    lastmodified: 1567120054790\
    id: apiuser\
    created_by: cbef5f0f-2f12-4c8c-98ab-0f2b0f74ca3f</p>

#### 5) Install the OM CLI - https://github.com/pivotal-cf/om#installation
`sudo wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | sudo  apt-key add -`\
`sudo echo "deb http://apt.starkandwayne.com stable main" | sudo  tee /etc/apt/sources.list.d/starkandwayne.list`\
`sudo apt-get update`\
`sudo apt-get install om -y`

#### 6) Export the OM Variables
`export OM_CA_CERT=/var/tempest/workspaces/default/root_ca_certificate`\
`export OM_CLIENT_ID=apiuser`\
`export OM_CLIENT_SECRET='VMware1!VMware1!'`\
`export OM_TARGET=https://localhost/uaa`\
`export OM_SKIP_SSL_VALIDATION=true`

#### 7) Get current list of VM flavors
`om curl -x GET --path /api/v0/vm_types > opsman_vm_types.json`
    
#### 8) Edit the file with mods/deletes/additions and save as opsman_vm_types_payload.json or something
`cp opsman_vm_types.json opsman_vm_types_payload.json`\
`vim opsman_vm_types_payload.json`

For example append "3xlarge.cpu" to the end of flavors
```
    ...
    {
      "name": "2xlarge.cpu",
      "ram": 16384,
      "cpu": 16,
      "ephemeral_disk": 65536,
      "builtin": false
    },
    {
      "name": "3xlarge.cpu",
      "ram": 16384,
      "cpu": 32,
      "ephemeral_disk": 65536,
      "builtin": false
    }
  ]
}
```
#### 9) Put the updated list of VM flavors

`om curl -x PUT --path /api/v0/vm_types --data "$(jq -c '.'  opsman_vm_types_payload.json)"`

    Status: 200 OK
    Cache-Control: no-cache, no-store
    Connection: keep-alive
    Content-Type: text/html
    Date: Thu, 29 Aug 2019 23:09:54 GMT
    Expires: Fri, 01 Jan 1990 00:00:00 GMT
    Pragma: no-cache
    Server: Ops Manager
    Strict-Transport-Security: max-age=15552000; includeSubDomains
    X-Content-Type-Options: nosniff
    X-Frame-Options: SAMEORIGIN
    X-Request-Id: f4ca56b0-1445-45bf-a119-92ad9547a653
    X-Runtime: 0.665806
    X-Xss-Protection: 1; mode=block

#### 10) Verify change took effect with
`om curl -x GET --path /api/v0/vm_types`


Ops Manager API Reference: https://docs.pivotal.io/pivotalcf/2-3/customizing/ops-man-api.html