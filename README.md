# Python Web Server Container Template

Production ready containerized project template for Python web applications using PostgreSQL and Redis.

## Usage

```bash
# Dev
docker compose up -d
# Prod
docker compose up -f compose.yml -f compose.production.yml -d
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
