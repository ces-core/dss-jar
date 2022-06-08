# DSS Jar

DSS module to simplify payments directly to Dai **Surplus Buffer**.

<!-- vim-markdown-toc GFM -->

- [Why?](#why)
- [What?](#what)
- [How?](#how)
- [Use Cases](#use-cases)
  - [RWA Stability Fee Collection](#rwa-stability-fee-collection)
  - [...](#)
- [Usage](#usage)
  - [Scripts](#scripts)
    - [`make nodejs-deps`](#make-nodejs-deps)
    - [`make build`](#make-build)
    - [`make test`](#make-test)
    - [`make deploy`](#make-deploy)
    - [`make create-jar`](#make-create-jar)
    - [`make verify`](#make-verify)
- [Contributing](#contributing)
  - [Dependencies](#dependencies)
  - [Dev Dependencies](#dev-dependencies)

<!-- vim-markdown-toc -->

## Why?

The Surplus Buffer is not a "first-class citizen" in DSS. It exists only as a concept, however there is no address to which one can send Dai to in order to increase the surplus buffer.

## What?

This module provides a contract which can:

1. Receive Dai as the destination of a `transfer` call.
2. Pull Dai from the users wallet and send it directly to the Surplus Buffer.

For 1., an additional transaction is required to actually send Dai to the Surplus Buffer, since currently Dai sticks to simple ERC-20 semantics and does not allow contracts to react when they receive.

## How?

A `Jar` implements the following interface:

```solidity
interface JarLike {
  function toss(uint256 wad) external;

  function flock() external;
}

```

- `toss(uint256 wad)`: pulls Dai from the sender&rsquo;s wallet and send it to the Surplus Buffer atomically.
- `flock()`: flushes any Dai balance of the `Jar` to the Surplus Buffer. Any Dai sent directly to it will simply accumulate until someone calls this function.

Effectively the 2 functions above will:

1. Burn ERC-20 Dai
2. Credit the due amount to the `Vow`&rsquo;s balance in the `Vat`.

## Use Cases

### RWA Stability Fee Collection

`Jar`s make it easier for off-chain collateral deals (RWA) to differentiate stability fee payments from collateral repayments. Each deal can have a different `Jar` instance to collect stability fees off-chain, while the accounting mechanism of the vault is made simpler by setting Stability Fees to `0`.

RWA partners can simply send Dai to the `Jar` address related to the deal and someone will periodically and permissionlessly flush the Dai to the Surplus Buffer.

### ...

## Usage

`Jar` instances can be easily created by the companion factory `JarFactory` (look for `JAR_FAB` in DSS chainlog):

```solidity
interface JarFactoryLike {
  function createJar(
    bytes32 ilk,
    address daiJoin,
    address vow
  ) external returns (Jar);
}

```

This factory allows creating 1 `Jar` per `ilk` (collateral type) in DSS.

To obtain the parameters you can:

- `bytes32 ilk`
  ```
  cast --from-ascii 'RWA010-A' # change to the actual ILK representing the deal
  ```
- `address daiJoin` and `adress vow`
  - For the official MCD deployments (both Goerli and Mainnet), go to the [chainlog](https://chainlog.makerdao.com/) and look for:
    - `MCD_DAI_JOIN`
    - `MCD_VOW`
  - For CES MCD on Goerli, go to the [reference repo](https://github.com/clio-finance/ces-goerli-mcd/blob/master/contracts.json) and look for:
    - `MCD_DAI_JOIN`
    - `MCD_VOW`

### Scripts

#### `make nodejs-deps`

Installs all node.js deps.

Usage:

```bash
make nodejs-deps
```

#### `make build`

Builds the current project with the predefined settings with `forge build`.

Usage:

```bash
make build
```

#### `make test`

Runs all tests with `forge test`.

⚠️ **ATTENTION:** This project requires testing with [forking mode](https://book.getfoundry.sh/forge/forking-mode.html). Make sure to set the `ETH_RPC_URL` environment variable pointing to a valid **Goerli** node before running it.

Usage:

```bash
make build
```

#### `make deploy`

Deploys a new `JarFactory` instance and verifies it.

Usage:

```bash
make deploy
```

#### `make create-jar`

Creates a new `Jar` instance from a given `JarFactory`.

Usage:

```bash
make create-jar factory='<FACTORY_ADDRESS>' \
    ilk=$(cast --from-ascii '<ILK_NAME>') \
    dai_join=$MCD_JOIN_DAI \
    vow=$MCD_VOW
```

#### `make verify`

Verifies a contract in Etherscan.

Usage:

```bash
# Without constructor args:
make verify \
    address=<address> \
    contract=src/JarFactory.sol:JarFactory

# With constructor args:
make verify \
    address=<address> \
    contract=src/Jar.sol:Jar \
    verify_opts="--constructor-args=$(cast abi-encode 'constructor(address,address)' "$MCD_JOIN_DAI" "$MCD_VOW")"
```

## Contributing

### Dependencies

- [`make`](https://www.gnu.org/software/make/)
- [`foundry`](https://github.com/foundry-rs/foundry)

### Dev Dependencies

- [`node>=14.0.0`](https://nodejs.org/en/)
- [`yarn@1.x`](https://classic.yarnpkg.com/lang/en/)
