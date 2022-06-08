# include .env file and export its env vars
# (-include to ignore error if it does not exist)-include .env
-include .env

nodejs-deps:; yarn install


# install solc version
# example to install other versions: `make solc 0_8_14`
FOUNDRY_SOLC_VERSION := 0_8_14

# Build & test
build:; forge build
clean:; forge clean
test:; forge test -vvv --fork-url=$(ETH_RPC_URL)

# Deploy
deploy:; @scripts/deploy.sh --verify src/JarFactory.sol:JarFactory

# Create Jar
create-jar:; @scripts/create-jar.sh --verify --factory=$(factory) --ilk=$(ilk) --dai-join=$(dai_join) --vow=$(vow)

# Verify a contract
verify_opts ?=
verify:; @scripts/verify.sh --address=$(address) --contract=$(contract) $(verify_opts)
