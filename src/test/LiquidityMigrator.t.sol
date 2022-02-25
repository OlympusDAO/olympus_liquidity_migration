// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../LiquidityMigrator.sol";
import "../interface/ITreasury.sol";
import "../interface/IHevm.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LiquidityMigratorTest is DSTest {
    LiquidityMigrator liquidityMigrator;

    ITreasury treasury = ITreasury(0x9A315BdF513367C0377FB36545857d12e85813Ef);
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address gUniRouter = 0x513E0a261af2D33B46F98b81FED547608fA2a03d;

    address gUniPool = 0x61a0C8d4945A61bF26c13e07c30AF1f1ca67b473;
    address ohm_fraxLpAddress = 0xB612c37688861f1f90761DC7F382C2aF3a50Cc39;

    address olympusGovernor = 0x245cc372C84B3645Bf0Ffe6538620B04a217988B;
    uint256 amount = 24531853941907362845;

    function setUp() public {
        liquidityMigrator = new LiquidityMigrator();
    }

    function testShouldFailIfCallerIsNotOwner() external {
        hevm.prank(hevm.addr(1));
        hevm.expectRevert("Ownable: caller is not the owner");

        liquidityMigrator.executeTx(
            dexRouter,
            gUniRouter,
            gUniPool,
            ohm_fraxLpAddress,
            amount,
            999
        );
    }

    function testShouldFailIfContractAddressIsNotLiquidityManager() external {
        hevm.expectRevert("Treasury: not approved");

        liquidityMigrator.executeTx(
            dexRouter,
            gUniRouter,
            gUniPool,
            ohm_fraxLpAddress,
            amount,
            999
        );
    }

    function testShouldFailIfAmountToGetFromTreasuryIsAboveTreasuryBalance()
        external
    {
        helper();
        hevm.expectRevert("TRANSFER_FAILED");

        liquidityMigrator.executeTx(
            dexRouter,
            gUniRouter,
            gUniPool,
            ohm_fraxLpAddress,
            64531853941907362845,
            999
        );
    }

    function testExecuteTx() public {
        helper();

        liquidityMigrator.executeTx(
            dexRouter,
            gUniRouter,
            gUniPool,
            ohm_fraxLpAddress,
            amount,
            999
        );

        (
            ,
            ,
            uint256 contractToken0BalAfterAddingLiquidity_,
            uint256 contractToken1BalAfterAddingLiquidity_
        ) = liquidityMigrator.getTokenInfo(
                ohm_fraxLpAddress,
                address(liquidityMigrator)
            );

        (
            uint256 contractV2lpBalanceBeforeRemovingLiquidity,
            uint256 contractV2lpBalanceAfterRemovingLiquidity,
            uint256 contractToken0BalBeforeAddingLiquidity_,
            uint256 contractToken1BalBeforeAddingLiquidity_,
            uint256 expectedToken0ToBeAddedOnGuni,
            uint256 expectedToken1ToBeAddedOnGuni,
            address lps
        ) = liquidityMigrator.transactions(liquidityMigrator.txCount() - 1);

        assertEq(amount, contractV2lpBalanceBeforeRemovingLiquidity);
        assertEq(0, contractV2lpBalanceAfterRemovingLiquidity);

        assertEq(
            contractToken0BalBeforeAddingLiquidity_ -
                expectedToken0ToBeAddedOnGuni,
            contractToken0BalAfterAddingLiquidity_
        );

        assertEq(
            contractToken1BalBeforeAddingLiquidity_ -
                expectedToken1ToBeAddedOnGuni,
            contractToken1BalAfterAddingLiquidity_
        );
    }

    function testWithdrawTokensLeft() external {
        helper();

        liquidityMigrator.executeTx(
            dexRouter,
            gUniRouter,
            gUniPool,
            ohm_fraxLpAddress,
            amount,
            950
        );

        (address token0, address token1, , ) = liquidityMigrator.getTokenInfo(
            ohm_fraxLpAddress,
            ohm_fraxLpAddress
        );

        balanceChecker(token0);
        balanceChecker(token1);
    }

    function balanceChecker(address addr_) public {
        if (IERC20(addr_).balanceOf(address(liquidityMigrator)) != 0) {
            uint256 contractBalBeforeTx = IERC20(addr_).balanceOf(
                address(this)
            );
            uint256 liquidityMigratorBalBeforeTx = IERC20(addr_).balanceOf(
                address(liquidityMigrator)
            );

            liquidityMigrator.withdrawToken(addr_);

            uint256 contractBalAfterTx = IERC20(addr_).balanceOf(address(this));
            uint256 liquidityMigratorBalAfterTx = IERC20(addr_).balanceOf(
                address(liquidityMigrator)
            );

            assertEq(contractBalAfterTx, liquidityMigratorBalBeforeTx);
            assertEq(liquidityMigratorBalAfterTx, 0);
        }
    }

    function helper() public {
        hevm.prank(olympusGovernor);

        treasury.enable(
            ITreasury.STATUS.LIQUIDITYMANAGER,
            address(liquidityMigrator),
            address(liquidityMigrator)
        );
    }
}
