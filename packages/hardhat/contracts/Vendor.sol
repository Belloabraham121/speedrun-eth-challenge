pragma solidity 0.8.4; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	// Custom errors
	error AddressZeroDetected();
	error ZeroAmountNotAllowed();
	error ContractBalanceNegligible();

	// events
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

	// state variables
	YourToken public yourToken;
	uint256 public constant tokensPerEth = 100;

	// constructor function
	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() external payable {
		if (msg.sender == address(0)) revert AddressZeroDetected();
		if (msg.value == 0) revert ZeroAmountNotAllowed();

		uint amountOfTokens = msg.value * tokensPerEth;

		yourToken.transfer(msg.sender, amountOfTokens);

		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() external onlyOwner {
		if (address(this).balance == 0) revert ContractBalanceNegligible();

		payable(owner()).transfer(address(this).balance);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) external {
		if (msg.sender == address(0)) revert AddressZeroDetected();
		if (_amount == 0) revert ZeroAmountNotAllowed();

		uint amountEthForTokens = (_amount / tokensPerEth) * 1e18;

		// transfer tokens from user to contract
		yourToken.transferFrom(msg.sender, address(this), _amount);

		// pay seller
		payable(msg.sender).transfer(amountEthForTokens / 1e18);

		// emit event
		emit SellTokens(msg.sender, _amount, amountEthForTokens);
	}
}
