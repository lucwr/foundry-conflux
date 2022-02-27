// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Swapper.sol";
import "../Token1.sol";
import "../Token2.sol";
import "../../lib/hevm.sol";
import "../../lib/console.sol";

contract SwapperTest is DSTest, ISwapper {
    address owner1 = 0x2c5F2886100114C10833dF2E52Ebfab54D59dfc9;
    address sender = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    Hevm vm = Hevm(HEVM_ADDRESS);
    Swapper s;
    Token1 t1;
    Token2 t2;
    uint256 ORDER;

    function setUp() public {
        s = new Swapper();
        vm.prank(owner1);
        t1 = new Token1();
        t2 = new Token2();
        //manually change ether balance of owner1 so he has gas
        vm.deal(owner1, 1e19);
    }

    //owner1 places an order of 100Token1 for 10 Token2
    function testSwap() public {
        t2.approve(address(s), 100e18);
        //start address impersonation of owner1
        vm.startPrank(owner1);
        t1.approve(address(s), 100e18);
        OrderIn memory oIn = OrderIn(
            address(t1),
            uint96(block.timestamp + 20000),
            100e18,
            10e18,
            address(t2)
        );

        ORDER = s.placeOrder(oIn);
        //stop address impersonation
        vm.stopPrank();
        console.log(t1.balanceOf(owner1));
        //msg.sender fulfills owner1 token order
        s.fulfillOrder(ORDER, 10e18);
        //perform equality checcks
        assertEq(t1.balanceOf(sender), 10e18);
        assertEq(t2.balanceOf(owner1), 1e18);
    }
}
