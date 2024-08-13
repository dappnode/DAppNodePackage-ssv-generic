# **SSV / SSV Holesky**

The SSV Network is a decentralized, open-source Ethereum staking network that enhances validator key security and network redundancy using Distributed Validator Technology (DVT). This package allows you to run an SSV Operator Node on mainnet, or for the Holesky testnet.

## Requirements

1. This package **requires a synced Node**, configured in the [Stakers UI](http://my.dappnode/stakers/ethereum) in order to function properly.

2. Ensure to **download the Backup** from the Backup tab immediately after completing Operator registration to secure all critical files.

## Registration Steps

1. Begin the installation of the package by selecting "New Operator" as the setup mode.

2. Obtain the operator public key, which is displayed in the package Info tab

3. Complete the registration as an operator by following the guidelines provided in the [SSV documentation](https://docs.ssv.network/operator-user-guides/operator-management/registration), using the public key from the previous step.

## DKG Setup Steps

1. Verify that your operator is registered on the SSV network, and confirm that the DKG service is running by checking the SSV Info tab.

2. Configure your node as a DKG endpoint by adding your DKG endpoint in the [SSV App Operator Config](https://app.ssv.network/my-account/operator/edit-metadata). The DKG endpoint will be:
    - For holesky: `http://<your-public-ip>:14515`
    - For mainnet: `http://<your-public-ip>:14516`

## Troubleshoting

- If the `OPERATOR_ID` is not retrieved automatically by the DKG service from the SSV API, you can manually enter it in the [SSV Config Tab](http://my.dappnode/packages/my/ssv-holesky.dnp.dappnode.eth/config).

- Remember the DKG port (14515 or 14516) must be open in your router. If UPnP is enabled, this will be done automatically.

For comprehensive information and additional resources, refer to the full official documentation [here](https://docs.ssv.network/learn/introduction).
