# Olympus Liquidity Migration

With the launch of Uniswap V3, which gives users the ability to offer concentrated liquidity in the price range of their choice resulting to high fees accrued as opposited to fees accrued in V2.

This repo offers a guide on how the treasury LPs on V2 pools are migrated to V3 pools using Gelato based on it being a relatively simple solution (focused on the basic tooling to set up and manage a v3 position), with good documentation that is audited and has been live for several months.

In summary the steps involved to achieved this are;

1. Create Uniswap V3 pool for token pair
2. Initialize the pool and add some full range liquidity to Uniswap V3 pool
3. Create G-UNI pool with multisig as manager
4. Set G-UNI parameters to 97.5% manager fee and 1% trigger for automatic fee withdrawal
5. Remove LP tokens from V2 pools
6. Add tokens using AddLiquidity in the G-UNI pool
7. Move all G-UNI LP tokens to the Treasury v2 contract

As fees accrue, move fees from multisig to the treasury.

The community vote (OIP-26) to move the OHM-FRAX pool to Uniswap v3 passed on Sep 25. Hence we'd be migrating OHM-FRAX pool on Uniswap V2 first. You can get more insight [here](https://docs.google.com/document/d/1fVlHsmanoXdXZhJofToDTRGJDJE-2ASb8NY2iM2otUg/)

# To Test

Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

Install Foundry
cargo install --git https://github.com/gakonst/foundry --bin forge

Run `forge build` to compile contracts

Run `forge test -vvvv -f https://mainnet.infura.io/v3/your_infura_id ` to run test via forked mainnet
