SHELL := /bin/bash
RM=rm

ContrPath=$(shell find src -name '*.sol')
ContrDirs=$(dir $(shell find src -name '*.sol'))
ContrFiles=$(notdir $(shell find src -name '*.sol'))
ContrDirsAndFiles=$(foreach v, $(ContrPath), $(dir $v) $(notdir $v))


# NULL=$(shell source .env)
include .env


.PHONY: build test

all: rebuild

install:
	forge install
	pnpm i

update:
	forge update

fmt:
	forge fmt

lint:
	pnpm run lint

chain:
	anvil --host 127.0.0.1 -p 8545 --chain-id 9527 -b 5 -a 10 --balance 10000000000000

types:
	pnpm run types

compile:
	forge build
	# mkdir -p build/abis
	# forge inspect -C src Counter abi > build/abis/Counter.abi

build: compile types

rebuild: clean build

clean:
	forge clean
	$(RM) -rf build

test:
	forge test --gas-report -vv
	# forge snapshot --gas-report --snap gas_usage1.txt
	# forge snapshot --gas-report --diff gas_usage1.txt

dep:
	# source .env
	# The cmd option '--broadcast' is used to actually send transactions to the real chain instead of simulating execution in local memory.
	forge create --private-key $(PRIVATE_KEY) --broadcast --value 0.0001ether src/Counter.sol:Counter --constructor-args 10
	forge create --private-key $(PRIVATE_KEY) --broadcast --value 0.0001ether src/Counter.sol:Counter --constructor-args 10 --verify --verifier etherscan -e $(ETHERSCAN_API_KEY) 

verify:
	# source .env
	forge verify-contract --watch --verifier etherscan -e $(ETHERSCAN_API_KEY) --constructor-args $$(cast abi-encode "constructor(uint256)" 10) $(COUNTER_DEPLOY_ADDR) src/Counter.sol:Counter

task1:
	# source .env
	forge script script/Counter.s.sol:CounterScript --private-key $(PRIVATE_KEY) -v --broadcast
	forge script script/Counter.s.sol -s "run(uint256)" --private-key $(PRIVATE_KEY) -v --broadcast 20
