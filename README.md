# IUPD

**IUPD Demo Project - To BE UPDATED**

## Table of Contents

- [Setup](#setup)
- [How to Run the Code](#how-to-run-the-code)

## Setup

Before running the project, we need provide some essential configuration and authentication info:

1. **Adjust Volume Mapping**:  
   Update the volume mapping in `docker/docker-compose.yaml` under `services.iupd.volumes`.

2. **Contruct .env File**:  
   Upload .env file, which contains all authentication information, to `docker` folder, following env_template file.
   Assign a UUID in the `.env` file located at `docker/.env`.

## How to Run the Code

To run the project, run the following command at `docker` folder:

```bash
docker-compose --env-file .env up --build
```

May need to cleanup previous containers and rebuild the image
