pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';

import './YourToken.sol';
import 'hardhat/console.sol';

contract Vendor is Ownable {
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 tokenAmount = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, tokenAmount);
    emit BuyTokens(msg.sender, tokenAmount, tokensPerEth);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, 'owner has not enough balance to withdraw');

    (bool sent, ) = msg.sender.call{value: address(this).balance}('');
    require(sent, 'Failed to send user balance back to owner');
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmtToSell) public {
    // check requested amt is greater than zero
    require(tokenAmtToSell > 0, 'token amount shoulde be greater than zero');

    // check user balance
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmtToSell, 'your balance is less than requested amount');

    // check vendor balance
    uint256 amountOfETHToTransfer = tokenAmtToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, 'vendor has not enough balance to sell');

    bool sent = yourToken.transferFrom(msg.sender, address(this), tokenAmtToSell);
    require(sent, 'failed  to transfer token from user to vendor');

    (sent, ) = msg.sender.call{value: amountOfETHToTransfer}('');

    require(sent, 'failed to send ETH to user');
  }
}
