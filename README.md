# IUPD

**IUPD Demo Project**

## Table of Contents

- [How to Run the Code](#how-to-run-the-code)
- [Setup](#setup)

## How to Run the Code

To run the project:

1. **Use the provided `run.sh` script to start the project**:

   ```bash
   ./run.sh
   ```

   **Noted that:**
   We need `auth.env` as described in the **Setup** section

   - If `auth.env` is created, you can choose to use it or enter sensitive information.
   - If `auth.env` is not created, you will be prompted to enter sensitive information (e.g., hostnames, usernames, passwords, and UUID) at runtime.

## Setup

Before running the project, we need to provide some essential configuration and authentication info:

1. **Application Configuration (`app_config.env`)**:

   - **We provide default configuration for setting up fast-probing application and connecting to server**
   - You can modify `app_config.env` according to your need.
   - This file does **NOT** contain any sensitive information.

2. **Authentication Configuration (`auth.env`)**:
   - **This file is essential for connecting to remote storage**
   - Create a `auth.env` file in the `docker` folder, following the structure of the provided `sensitive_template.env` and assign values to the required sensitive fields like usernames, passwords, and UUID.
   - This file contains sensitive information
