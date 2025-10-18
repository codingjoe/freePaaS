# Python Web Server Container Template

Production ready containerized project template for Python web applications using PostgreSQL and Redis.

## Usage

```
curl -fsSL https://raw.githubusercontent.com/codingjoe/python-template/main/bin/install.sh | sh
```

```bash
# Dev
docker compose up -d
# Prod
docker compose -f compose.yaml -f compose.production.yaml up -d
```

## Features

- Use tiny [Distroless] images for production
- High availability setup with multiple web servers behind a load balancer
- Automatic HTTPS with Let's Encrypt via [Caddy]
- [PostgreSQL] database with daily backups
- [Redis] for caching and co
- Install Python version and it's dependencies using [uv]

## Set up

1. Copy `.env.example` to `.env` and fill in the required values.
1. Update `Caddyfile` with your domain and email for Let's Encrypt.
1. ```bash
   python -c 'import secrets; print(secrets.token_urlsafe())' > secrets/postgres_password.txt
   ```

[caddy]: https://caddyserver.com/
[distroless]: https://github.com/GoogleContainerTools/distroless
[postgresql]: https://www.postgresql.org/
[redis]: https://redis.io/
[uv]: https://docs.astral.sh/uv/
