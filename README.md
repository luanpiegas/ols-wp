# Modern WordPress Docker setup

Start a new WordPress project using Docker, with batteries included:

- OpenLiteSpeed server
- MariaDB
- Redis
- Adminer
- WP CLI

## Local domains for multiple stacks

This project is configured to run behind a shared local `nginx-proxy` gateway so multiple Docker stacks can stay up at the same time without fighting over port 80.

Use a `*.localhost` domain for each stack. Those names resolve to `127.0.0.1` automatically, so no hosts-file changes are required.

### One-time proxy setup

```bash
docker compose -f proxy/docker-compose.yml up -d
```

### Per-project setup

1. Copy `.env.example` to `.env`.
2. Set a unique `STACK_NAME`, for example `blog`.
3. Set a unique `DOMAIN`, for example `blog.localhost`.
4. Set a unique `OLS_ADMIN_PORT` if you also want the LiteSpeed admin panel available for multiple stacks at once.
5. Start the stack:

```bash
docker compose up --build -d
```

### URLs

- Site: `http://<DOMAIN>`
- Adminer: `http://db.<DOMAIN>`
- OpenLiteSpeed admin: `http://localhost:<OLS_ADMIN_PORT>`
