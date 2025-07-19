# IODA Upstream Delay

This repository provides instructions necessary to set up an IODA Upstream Delay Docker container and explains some of the configuration settings.

## How to set up a vantage point

### Clone this repository

The first step to setting up a vantage point is to clone this repository:

```git clone https://github.com/InetIntel/ioda-upstream-delay-container.git```

### Create and register an SSH key

The next step is to create an SSH key (or select one that already exists). This SSH key will be used for authentication when reporting measurement results. Once you have selected the SSH key to use, overwrite the file at `./ioda-upstream-delay-container/data/ssh_id` with your private key. This private key will be used to upload measurement results from your vantage point.

To register your vantage point, please share your public key (e.g., `id_rsa.pub`) with a member of the IODA team. Once the public key is registered, your vantage point will be able to upload files to the IODA server. 

NOTE: If your public key has not yet been registered with the IODA team, you may continue following the instructions below. However, until the public key is registered, measurement results will be stored/cached on the vantage point. On average, each measurement cycle generates approximately ~800 MB of data, so be sure that your machine has sufficient disk space for the probing interval specified (more on probing intervals below).

### Build the Docker container

Next, build the IODA Upstream Delay docker container. This can be done using Docker compose, by using one of the following commands (which to use depends on your version of Docker): 

```docker-compose build --no-cache```

or

```docker compose build --no-cache```

### Configure settings

Once the container is built (or while you are waiting for it to finish), you will need configure the vantage point's settings by modifying the `docker-compose.yaml` file. The existing `docker-compose.yaml` file in this directory provides a simplified template. Using this will run the vantage point with the default settings. Below is a list of important settings


**Volumes**

- **`./data` location:** Measurement results, logs, etc. will be stored in the `./data` directory in this repo. If you'd like to store this data in another location (e.g., on another disk or volume) please be sure to change the path listed under `volumes` in the docker-compose.yaml file (the path on the left refers to the path on the host machine). If you change the location of this directory, please be sure to move the `./data/ssh_id` file, as well. 

**Environmental variables**

- **`PROBE_RATE`:** This is the rate limit for sending packets, measured in packets per second (pps). 
- **`INTERVAL`:** The time interval between measurement cycles. Note that this is aligned to the machine's clock. For example, specifying an inverval of 1800 seconds (30 minutes) will start a measurement cycle on every half hour (5:00, 5:30, 6:00, etc.). Note that if a measurement cycle is unable to finish within the interval specified (due to a combination of a low probe rate and/or short interval), the next measurement cycle will be delayed and trigger on the next interval. In the above example, if interval is set to 30 minutes, but it takes 31 minutes to run, a measurement cycle will start every hour.
- **`BW_LIMIT`:** This sets the bandwidth limit of the file transfer for uploading measurement results. Currently, this can be specified in the same way as the `--bwlimit` flag to `rsync` (e.g., `--bwlimit=10m` will set a limit of 10 MBps). 

**Additional notes**

A vantage point should be able to finish a measurement cycle probing at 25k - 30k pps within a 30 minute measurement cycle. This packet rate can be increased/decreased depending on your preferences and network resources available.

In vertain cases, it may be necessary to tweak or modify the network configuration settings in. Currently, this is somewhat based on trial and error, but the `network_mode` specified in the provided `docker-compose.yaml` file seems to work the most consistently across different hosts. 

Below is an example with some of the additional environmental variables that can be specified. The values specified to these environmnetal variables will override the application's default values. 

```yaml
services:
  iupd:
    build:
      context: .
    container_name: iupd-container
    network_mode: host
    user: root
    cap_add:
      - NET_ADMIN
      - NET_RAW
    volumes:
      - ./data/:/data
    command: python3 main.py
    environment:
      - DEBIAN_FRONTEND=noninteractive
      - APP_ENV=docker
      - PROBE_RATE=30000 # Passed to yarrp command to set packet per second limit for probing
      - BW_LIMIT=10m # Passed to rsync to set bw limit for uploading measurement results
      - INTERVAL=1800 # Number of seconds between measurement cycles.
```

### Run the container

You can start the vantage point docker container by running the command (again, with or without the dash depending on your version of Docker):

```docker compose up -d iupd```

If you'd like to start the container in interactive mode you can omit the `-d` flag. However, most appliaction output is recorded in the log file at `./data/ioda-ud.log`. 

### Stopping the container

```docker compose stop iupd```

### Debugging and errors

If you run into issues, please feel free to reach out to the IODA team. If possible, sharing the log files generated (e.g., `./data/ioda-ud.log`) will up us diagnose any issues.
