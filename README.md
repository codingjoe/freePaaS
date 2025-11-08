<p align="center">
<img alt="freePaaS: Secure, convenient, fast & free forever!" src="logo.svg">
</p>

# freePaaS — Secure, convenient, fast & free forever!

Production ready services fully managed on a RaspberryPi (or any other machine):

- Lightweight runtime containers (Python, Nodejs, etc)
- Databases (PostgreSQL, Redis, etc)
- Automatic HTTPS with Let's Encrypt
- Monitoring & Logging
- Durability & Backups

No fuss automatic deployments straight form GitHub.

## Getting Started

```
sh <(curl -fsSL https://raw.githubusercontent.com/codingjoe/freePaaS/main/bin/install.sh)
```

```bash
# Dev
docker compose up -d
```

## Features

- Use tiny [Distroless] images for production
- High availability setup with multiple web servers behind a load balancer
- Automatic HTTPS with Let's Encrypt via [Caddy]
- [PostgreSQL] database with daily backups
- [Redis] for caching and co
- Install Python version and it's dependencies using [uv]

[caddy]: https://caddyserver.com/
[distroless]: https://github.com/GoogleContainerTools/distroless
[postgresql]: https://www.postgresql.org/
[redis]: https://redis.io/
[uv]: https://docs.astral.sh/uv/
