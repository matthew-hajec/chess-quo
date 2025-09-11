# Deployment

## Environment Variables

The following environment variables are expected to be set:

### `DATABASE_URL`

The URL of the database

Example:
- `ecto://postgres:postgres@localhost/cq

### `SECRET_KEY_BASE`

Generated using `mix phx.gen.secret`

Example:
- `qLpvhKrH82RPWzOgo7H1Q7G+VYxYdAfRz6DoPFTyO2ae08MDxxaIH1ajP1Z0vMh0`

### `PHX_HOST`

The Host of the endpoint.

Example:
- `chessquo.com`

### `PORT`

The port for the server to listen on

Example:
- `4000`