<p align="center">
<img alt="freePaaS: Secure, convenient, fast & free forever!" src="logo.svg">
</p>

# freePaaS — Secure, convenient, fast & free forever!

Production ready services fully managed on a RaspberryPi (or any other machine):

- PostgreSQL
- Redis
- Nodejs
- Python

No fuss automatic deployments straight form GitHub.

## Usage

```
curl -fsSL https://raw.githubusercontent.com/codingjoe/python-container/main/bin/install.sh | sh
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
