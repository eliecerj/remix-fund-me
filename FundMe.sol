// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
// 837,285 deploy gas fee
// 817,755 deploy gas fee(with constant in MINIMUM_USD
error NotOwner();
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    // 21,415 gas - constant
    // 23,515 gas - non-constant

    // 21,415 * 12000000000 = 256,980,000,000,000 (wei) = 0.00025698 eth * 1300 = 0.33 USD
    // 23,515 * 12000000000 = 282,180,000,000,000 (wei) = 0.00028218 eth * 1300 = 0.36 USD
    // gas price of eth goes up this could be a big difference

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;
    //21,508 gas - immutable
    //23,644 gas- non-immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?
        // revert will send remaining gas fee and do no perform action before it 
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); // 1e18 == 1 * 10 ** 18 = 1000000000000000000 wei == 1 eth
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        // withdraw the funds
        // transfer (thows error, revert tx automatically)
        // payable(msg.sender).transfer(address(this).balance);
        // send (return boolean, doesnt revert)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Sent failed");
        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner");
        // gas efficiency to use custom errors instead of require
        if(msg.sender != i_owner) { revert NotOwner(); }
        _; //do all within the function
    }

    // What happens if someone sends this contract ETH without calling the fund function


    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    

    
}
