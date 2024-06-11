// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Staking {
  struct Stake {
    uint256 amount;
    uint256 timestamp;
  }

  mapping(address => Stake) public stakes;
  address[] public stakers;
  uint256 public totalStaked;
  uint256 public rewardPool;

  event Staked(address indexed staker, uint256 amount);
  event Unstaked(address indexed staker, uint256 remainAmount, uint256 stakedAmount);
  event RewardDistributed(address indexed staker, uint256 reward);

  function stake() public payable{
    require(msg.value > 0, "Must stake non-zero amount");

    if(stakes[msg.sender].amount == 0) {
      stakes[msg.sender] = Stake(msg.value, block.timestamp);
      stakers[stakers.length] = msg.sender;
    } else {
      stakes[msg.sender].amount += msg.value;
    }
    totalStaked += msg.value;

    emit Staked(msg.sender, msg.value);
  }

  function unstake(uint256 _amount) public {
    require(stakes[msg.sender].amount > _amount, "No enough tokens to unstake");

    stakes[msg.sender].amount -= _amount;
    totalStaked -= _amount;

    payable(msg.sender).transfer(_amount);

    emit Unstaked(msg.sender, stakes[msg.sender].amount, _amount);
  }

  function distributeRewards() public {
    for(uint256 i = 0; i < getAllStakers().length; i++) {
      address staker = getAllStakers()[i];
      uint256 reward = calculateReward(stakes[staker].amount, stakes[staker].timestamp);
      if(reward > 0) {
        stakes[staker].amount += reward;
        rewardPool -= reward;
        emit RewardDistributed(staker, reward);
      }
    }
  }

  function calculateReward(uint256 _amount, uint256 _timestamp) internal view returns (uint256) {
    uint256 duration = block.timestamp - _timestamp;
    uint256 rewardRate = 1;
    return (_amount * duration * rewardRate) / (365 * 24 * 60 * 60 * 100);
  }

  function getAllStakers() internal view returns (address[] memory) {
    uint256 stakerCount = 0;
    for (uint256 i = 0; i < stakers.length; i++) {
      if (stakes[stakers[i]].amount > 0) stakerCount += 1;
    }

    address[] memory activeStakers = new address[](stakerCount);
    uint256 index = 0;
    for (uint256 i = 0; i < stakers.length; i++) {
      if (stakes[stakers[i]].amount > 0) {
          activeStakers[index] = stakers[i];
          index += 1;
      }
    }

    return activeStakers;
  }

  receive() external payable {
    rewardPool += msg.value;
  }
}