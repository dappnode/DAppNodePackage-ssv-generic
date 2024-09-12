# SSV Dappnode Package

The **SSV Network** (Secret Shared Validator) is a decentralized, open-source Ethereum staking network that enhances validator key security and network redundancy using **Distributed Validator Technology (DVT)**. This package allows you to run an **SSV Operator Node** along with its **DKG service** for distributed key generation, operating on either the Ethereum mainnet or the Holesky testnet.

### Services

This package includes the following services:

- **SSV Operator (`operator`)**:

  - The SSV Operator node is responsible for managing validator operations in a distributed setup. It uses a secret-shared key system to ensure security and redundancy across multiple operators.

  - The operator node interacts with both the execution and consensus layers of the Ethereum network. Configuration files for the operator are stored in `/data/operator/config`.

  - The operator runs behind the scenes using the `entrypoint.sh` script to handle key management, operator configuration, and node startup. Logs are stored in `/data/operator/logs`.

  - The **operator node** uses ports `12515` and `13515` for TCP/UDP communication, respectively.

- **DKG Service (`dkg`)**:

  - The **Distributed Key Generation (DKG)** service is responsible for generating secure validator keys in a distributed way, ensuring that no single operator has access to the complete key.

  - This service communicates with the SSV network to securely create and manage the validator keys. Configuration files for DKG are stored in `/data/dkg/config` and logs in `/data/dkg/logs`.

  - The DKG service uses port `14515` for the Holesky testnet and `14516` for the mainnet.

### Configuration

- **Setup Wizard**: The package includes a setup wizard that allows for easy configuration during the first installation or when importing an existing operator configuration. There are two options:

  - **New Operator / Update**: Set up a new operator or perform a simple update to an existing one.
  - **Import Operator**: Import an existing operator by uploading the encrypted private key and password.

- **DKG Configuration**: The DKG endpoint is automatically configured based on the network (mainnet or Holesky) and can be accessed through the respective public IP address:

  - For **Holesky**: `http://<your-public-ip>:14515`
  - For **Mainnet**: `http://<your-public-ip>:14516`

- **Operator Registration**: After installing the package, retrieve the operator public key from the Info tab and register it on the [SSV Network](https://app.ssv.network/my-account/operator/edit-metadata). Follow the instructions in the SSV documentation to complete the registration process.

### Script Integration

- **Staker Tools Integration**: The `dvt_lsd_tools.sh` script is sourced from the `staker-package-scripts` repository. It is downloaded during the Docker build process using the release version specified in the `STAKER_SCRIPTS_VERSION` argument. This script manages staking-related tasks and is placed in `/etc/profile.d/`.

- **Operator Initialization Scripts**:

  - Operator `entrypoint.sh`: Manages the initialization of the operator service, including key generation, configuration setup, and node startup.
  - DKG `entrypoint.sh`: Handles the setup and startup of the DKG service, ensuring that the operator keys are securely generated and stored.

  These scripts ensure proper startup and configuration of the operator and DKG services.

### Backup and Restore

The package supports backup and restore functionality for both the operator and DKG services:

- **Operator Config**: The configuration and keys for the operator are stored in `/data/operator/config`.
- **DKG Output**: The generated key shares from the DKG process are stored in `/data/dkg/output`.

It's recommended to download a backup immediately after completing the operator registration to secure all critical files.

For more detailed steps, please refer to the [SSV Network documentation](https://docs.ssv.network/learn/introduction).
