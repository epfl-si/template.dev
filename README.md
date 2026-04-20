

# Barcode dev kit

This repository provides a centralized development environment for Barcode project.
It provides setup and execution of all services required for local development.

Sub-repositories
* [Backend](https://github.com/epfl-si/barcode.backend)
* [Frontend](https://github.com/epfl-si/barcode.frontend)

## Sub-respositories management

Clone sub-repositories (backend + frontend)

```bash
make checkout
```

Update all sub-repositories

```bash
make git-pull
```

## Setup

Installation

```bash
make install
```

## Run

Start the database

```bash
make start-db
```

Start the backend

```bash
make start-backend
```

## Help

```bash
make help
```

## Command-line utility

### Prisma 

Doc: [Prisma CLI reference](https://www.prisma.io/docs/orm/reference/prisma-cli-reference)

Apply all migrations, then create and apply any new migrations

```bash
npx prisma migrate dev
```

Apply all migrations and create a new migration if there are schema changes, but do not apply it

```bash
npx prisma migrate --create-only
```
