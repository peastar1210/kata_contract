// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Deposits {
        uint256 depositAmount;
        uint256 depositTime;
        uint256 endTime;
        uint256 index;
        uint256 reward;
        bool paid;
    }

    struct Rates {
        uint64 newInterestRate;
        uint256 lockDuration;
        uint256 timeStamp;
        bool active;
    }

    mapping(address => Deposits[]) private deposits;
    Rates[] public rates;

    address public tokenAddress;
    uint256 public stakedBalance;
    uint256 public rewardBalance;
    uint256 public stakedTotal;
    uint256 public totalReward;
    uint64 public index;
    string public name;
    bool public isStopped;

    IERC20 public mainToken;
    IERC20 public jobToken;

    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount
    );

    event PaidOut(
        address indexed token,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    event RatesChanged();

    event RewardsAdded(uint256 rewards, uint256 time);

    event StakingStopped(bool status, uint256 time);

    constructor(
        string memory name_,
        address mainTokenAddress,
        address jobTokenAddress,
        uint64 rate_
    ) Ownable() {
        name = name_;
        require(mainTokenAddress != address(0), "Zero token address");
        require(jobTokenAddress != address(0), "Zero token address");
        mainToken = IERC20(mainTokenAddress);
        jobToken = IERC20(jobTokenAddress);
        require(rate_ != 0, "Zero interest rate");
        rates.push(Rates(rate_, block.timestamp, 2592000000, true));
        isStopped = false;
    }

    function getRates() external view returns (Rates[] memory) {
        return rates;
    }

    function setRateAndLockduration(uint64 rate_, uint256 _duration) external payable onlyOwner {
        require(rate_ != 0, "Zero interest rate");
        rates.push(Rates(rate_, block.timestamp, _duration, true));
        emit RatesChanged();
    }
    
    function removeRateAndLockduration(uint256 _index) external payable onlyOwner {
        rates[_index].active = false;
        emit RatesChanged();
    }

    function changeStakingStatus(bool _status) external payable onlyOwner {
        isStopped = _status;
        emit StakingStopped(_status, block.timestamp);
    }

    function userDeposits(
        address user
    ) 
        external
        view
        returns (Deposits[] memory)
    {
        return deposits[user];
    }

    function stake(
        uint256 _amount,
        uint256 _index
    ) 
        public
    {
        require(!isStopped, "not staking period");
        require(_amount > 0, "Cannot stake 0 tokens");
        mainToken.transferFrom(msg.sender, address(mainToken), _amount);
        Deposits memory newDeposit = Deposits(_amount, block.timestamp, block.timestamp.add(rates[_index].lockDuration), _index, calculateReward(_amount, rates[_index].newInterestRate), false);
        deposits[msg.sender].push(newDeposit);
        jobToken.transfer(msg.sender, _amount);
    }

    function unstake (uint256 _index) 
        public
    {
        require(!deposits[msg.sender][_index].paid, "already unstaked");
        require(block.timestamp > deposits[msg.sender][_index].endTime, "can't unstake yet");
        mainToken.transfer(msg.sender, deposits[msg.sender][_index].reward);
        deposits[msg.sender][_index].paid = true;
    }

    function calculateReward (uint256 _amount, uint64 _rate) private pure returns(uint256) {
        return _amount.mul(100 + uint256(_rate)).div(100);
    }
}
