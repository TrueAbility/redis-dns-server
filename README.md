# Redis Powered DNS Server in GoLang

This is a DNS server that uses Redis as the backend. Redis records are stored
according to the FQDN (with trailing dot) as the key, and a JSON payload as
the value.

The "d" executable located in /bin is a dns resolver used for the Kubernetes liveness probe.
It has been added to prevent an issue where the redis-dns server would fail to resolve ascreen.co.
If the DNS server is unable to resolve ascreen.co, just restart the pod.

You can find the repository here: https://github.com/TrueAbility/d

Below a sample of the Kubernetes deployment yaml configuration:

```yaml
livenessProbe:
exec:
  command:
    - /bin/sh
    - -c
    - /liveness_check.sh
initialDelaySeconds: 30
periodSeconds: 120
timeoutSeconds: 10
failureThreshold: 3
```

## How to set initial record for ascreen.co

Use redis-cli and add this value:

```
SET "ascreen.co." "{\"fqdn\":\"ascreen.co.\",\"cnames\":[\"us-east-1.antimony.io\"],\"ipv4_public_ips\":[],\"ipv6_public_ips\":[],\"mbox\":\"admin.trueability.com.\",\"mx_servers\":[],\"name_servers\":[\"ns01.trueability.com\",\"ns02.trueability.com\"],\"soa\":\"ascreen.co\",\"ttl\":300}"
```

For staging:

```
SET "bscreen.co." "{\"fqdn\":\"bscreen.co.\",\"cnames\":[\"us-east-1.antimony.io\"],\"ipv4_public_ips\":[],\"ipv6_public_ips\":[],\"mbox\":\"admin.trueability.com.\",\"mx_servers\":[],\"name_servers\":[\"ns01.falseability.com\",\"ns02.falseability.com\"],\"soa\":\"bscreen.co\",\"ttl\":300}"
```

## JSON Payload:

```json
{
    "cnames": ["foo-12345.example.com."],
    "fqdn": "foo-12345.example.com.",
    "id": 27469,
    "ipv4_public_ips": ["104.0.0.1"],
    "ipv6_public_ips": [],
    "mbox": "admin.example.com."
    "mx_servers": [],
    "name_servers": ["ns1.example.com", "ns2.example.com"],
    "soa": "example.com"
    "ttl": 300,
}
```

- supply cnames or ipv4_public_ips, not both
- mbox admin.example.com # Don't use '@' in DNS email addresses
- wildcard records, eg. `www.foo-12345.example.com.` are supported. The Redis
  key for wildcards is `*.foo-12345.example.com.`.

## Usage:

```
./redis-dns-server \
    -redis-server-url redis://127.0.0.1:6379 \
    -port 5300
```

Port `53` is the standard port. Using a port less than `1024` will require
root privileges.

## Development

### Building

General build steps:

Download from github and build using golang 1.11
Dependencies are automatically installed

```

$ go build
$ ./redis-dns-server --help

```

### Using Vagrant

A simple `Vagrantfile` is provided to quickly spin up an Ubuntu 14.04 LTS box,
that already has GoLang installed, as well as the latest version of Docker,
and Docker Compose.

```

$ vagrant up
$ vagrant ssh

```

Inside Vagrant, the current working project directory will be accessible at
`/vagrant`.

### Using Docker and Docker Compose

Either from your local machine running Docker, or from within the Vagrant box:

```

$ cp -a docker-compose.env.example docker-compose.env
$ docker-compose up

```

To rebuild the image manually:

```

$ docker-compose build

```

## Deployment

### Docker

Reference the above Development section for using Docker Compose.
Alternatively, Redis DNS Server can be deployed with Docker in the following
fashion.

#### Building

```

$ make linux
$ docker build -t 'redis-dns-server:latest' .

```

#### Linking With a Redis Container

```

$ docker run -tid --name redis redis
$ docker run -itd \
    -e DOMAIN="example.com" \
    -e HOSTNAME="myhostname.example.com" \
    --link redis:db \
    -p 53:53 \
    redis-dns-server:latest

```

#### Linking With an External Redis Server

```

$ docker run -itd \
    -e DOMAIN="example.com" \
    -e HOSTNAME="myhostname.example.com" \
    -e REDIS_HOST="redis.example.com" \
    -p 53:53 \
    redis-dns-server:latest

```

#### Using an Environment File

You can load all `ENV` variables from an `ENV` file. An example `ENV` file
can be found at `docker-compose.env.example`, and looks something like:

```

REDIS_HOST=redis.example.com
REDIS_PORT=6379
REDIS_DB=0
REDIS_USERNAME=myuser
REDIS_PASSWORD=mypassword
DOMAIN=example.com
DOMAIN_EMAIL=admin.example.com
HOSTNAME=myhostname.example.com

```

Using it:

```
$ docker run -itd \
    --env-file /path/to/myenv.file \
    -p 53:53 \
    redis-dns-server:latest
```

## Inspiration:

- https://github.com/ConradIrwin/aws-name-server
- https://github.com/miekg/dns

## TODO List:
