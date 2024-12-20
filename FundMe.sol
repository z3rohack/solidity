// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address [] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable i_owner;

    constructor () {
        i_owner = msg.sender;
    }

    function fund() public payable{
        // allow users to send $
        // min. amount to send $5
 
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 ** 18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        
        // for loop
        // [0,1,2,3,4 ...]
        // for loop syntax
        // for(starting index, ending index, step amount)
        for(uint256 funderIndex =0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            }
        // reset array to 0
        funders = new address[](0);
        //ways to send funds --> transfer, send, call
        //msg.sender= address
        //payable(msg.sender) = payable address (typecasting)
        //transfer
        //payable(msg.sender).transfer(address(this).balance);
        //send
       // bool sendSuccess = payable(msg.sneder).send(address(this).balance);
       // require(sendSuccess, "Send Failed");
        //call most common way
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    // executed where owner is required put after public in function call
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) { revert NotOwner();}
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();    
    }
    

    }



