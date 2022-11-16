pragma solidity 0.8.6;
 SPDX-License-Identifier MIT


import hardhatconsole.sol;
import @openzeppelincontractsaccessOwnable.sol;

contract Staker is Ownable {

these beautiful pieces of code allow us to keep track of when we deposit eth and how much
mapping(address = uint256) public balances; 
mapping(address = uint256) public depositTimestamps;

time within funds must be deposited (condition set by shop etc.)
uint256 public depositDeadline = block.timestamp + 3 minutes; 

time within funds must have been returned else are auto-returned, should there be funds left.
uint256 public returnDeadline = block.timestamp + 6 minutes; 

current block 
uint256 public currentBlock = 0;

bool public canWithdraw = false;

event for when someone stakes, lists sender and amount
event Stake(address indexed sender, uint256 amount); 

event for when 
event Received(address, uint); 

event for when 
event Execute(address indexed sender, uint256 amount);

defining an owner rights system to restrict access to a certain function


function to calculate how much time is left to deposit
 function depositTimeLeft() public view returns (uint256) {
     checks to ensure deposit deadline hasn't occured yet
    if( block.timestamp = depositDeadline) {
      return (0);
    } else {
    returns time until deadline
      return (depositDeadline - block.timestamp);
    }
  }

function to calculate how much time until funds get auto-returned, should there be funds left.
 function returnPeriodLeft() public view returns (uint256 claimPeriodLeft) {
    checks to ensure return deadline hasn't occured yet
    if( block.timestamp = returnDeadline) {
      return (0);
     returns time until return deadline
    } else {
      return (returnDeadline - block.timestamp);
    }
  }

modifiers, which run before and after function calls, are ideal for controlling whether functions
are going to run or not because thats kinda epic and yeh (later we will control whether u can stake)

checks if deposit deadline is reached
  modifier depositDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = depositTimeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, Deposit period hasn't begun yet lmao);
    } else {
      require(timeRemaining  0, Deposit period has already elapsed lmao);
    }
    _;
  }

  modifier returnDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = returnPeriodLeft();
    if( requireReached ) {
      require(timeRemaining == 0, Return funds deadline is not reached yet lmao);
    } else {
      require(timeRemaining  0, Return funds deadline has been reached lmao);
    }
    _;
  }



staking function (kinda self explanatory, uses modifiers to control 
whether it can run based on being before claimdeadline and within staking deadline)
  function stake() public payable depositDeadlineReached(false) returnDeadlineReached(false) {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    depositTimestamps[msg.sender] = block.timestamp;
    emit Stake(msg.sender, msg.value);
  }

withdraw function, note how it's private so only the contract can call it, 
modifier to ensure this is before return deadline.
  function returnFunds(address returnFundsTo) private returnDeadlineReached(false) {
    require(balances[returnFundsTo]  0, No balance to withdraw lol- you have either already emptied it or funds have not been staked.);
    uint256 individualBalance = balances[returnFundsTo];
    
    

    transfer funds back via call
    (bool sent,) = msg.sender.call{value individualBalance}();
    require(sent, ur withdrawal failed this kinda sucks rip );
  }

returns funds after the return deadline has been met
  function returnFundsAfterDeadline() public returnDeadlineReached(true) {
    require(balances[msg.sender]  0, No balance to withdraw lol- you have either already emptied it or funds have not been staked.);
    uint256 individualBalance = balances[msg.sender];
    transfer funds back via call
    (bool sent,) = msg.sender.call{value individualBalance}();
    require(sent, ur withdrawal failed this kinda sucks rip );
  }

 receive() external payable {
      emit Received(msg.sender, msg.value);
  }


}



