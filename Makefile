-include .env

# Update Dependencies
update :; forge update

build :; forge build

test :; forge test

anvil :; anvil -m 'test test test test test test test test test test test junk' 

anvil-steps :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

snapshot :; forge snapshot

format :; forge fmt

# Deploy it on Sepolia Testnet
deploy-sepolia:;	forge script script/DeployFundMe.s.sol:DeployFundMe \
					--rpc-url $(SEPOLIA_RPC_URL) \
					--private-key $(PRIVATE_KEY) \
					--broadcast \
					--verify \
					--etherscan-api-key $(ETHERSCAN_API_KEY) \
					-vvvv \


# Deploy it on Local ANVIL Chain
deploy-anvil:;	forge script script/DeployFundMe.s.sol:DeployFundMe \
				--rpc-url $(ANVIL_RPC_URL) \
				--private-key $(DEFAULT_ANVIL_KEY) \
				--broadcast \
				-vvvv



