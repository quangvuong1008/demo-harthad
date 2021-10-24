//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is Ownable {
    mapping(address => bool) public supportTokens;
    address public contractOwner;

    struct tokenInfo {
        uint256 amount;
        uint16 cost;
        uint16 numberRate;
    }
    uint256 public immutable COST_ETH;

    // Info of each user.
    struct UserInfo {
        uint256 totalAmount; // How many total amount the user has provided. type = USD
        mapping(address => tokenInfo) amountToken; // How many amountToken the user has provided
        bool inBlackList;
    }

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;
    // Info of each pool.
    struct PoolInfo {
        address pToken; // Address of LP token contract.
        uint256 apyReward; // reward
        uint256 apyBorrow; // borrow
        uint256 numberRate; // rate
    }

    uint256 public apyReward;
    uint256 public apyBorrow;
    uint256 public numberRate;
    // Info of each pool.
    PoolInfo[] public poolInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor() public {
        // hard-code cost of eth
        COST_ETH = 4000;
        // busdToken is supported
        supportTokens[0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] = true;
    }

    function addToken(address _tokenAddress, uint256 _ratio) public onlyOwner {
        require(!supportTokens[_tokenAddress], "Tokens are available");
        supportTokens[_tokenAddress] = true;
        // lending pool
        apyReward = 2500;
        apyBorrow = 50000;
        numberRate = 1000000;
        poolInfo.push(
            PoolInfo({
                pToken: _tokenAddress,
                apyReward: 25000, // 2.5%
                apyBorrow: 50000, // 5%
                numberRate: 1000000
            })
        );
    }

    function setBlackList(address _blacklistAddress) public onlyOwner {
        userInfo[_blacklistAddress].inBlackList = true;
    }

    function removeBlackList(address _blacklistAddress) public onlyOwner {
        userInfo[_blacklistAddress].inBlackList = false;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        // PoolInfo storage pool = poolInfo[_pid];
        // To do
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Stake tokens to Pool
    function deposit(address _tokenAddress, uint256 _amount) external payable {
        // PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require(!user.inBlackList, "in black list");
        updatePool(0);
        if (_tokenAddress == address(0)) {
            require(msg.value == _amount, "not enough");
            user.amountToken[_tokenAddress].amount += msg.value;
        } else {
            require(
                supportTokens[_tokenAddress],
                "This token is not supported"
            );
            user.amountToken[_tokenAddress].amount += _amount;
            user.amountToken[_tokenAddress].cost = 1;
            user.amountToken[_tokenAddress].numberRate = 100;
            bool sent = IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            require(sent, "Transfer failed");
        }

        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw tokens from STAKING.
    function withdraw(address _tokenAddress, uint256 _amount) external {
        // PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require(
            user.amountToken[_tokenAddress].amount >= _amount,
            "withdraw: not good"
        );
        updatePool(0);
        if (_tokenAddress == address(0)) {
            user.amountToken[_tokenAddress].amount -= _amount;
            (bool sent, ) = msg.sender.call{value: _amount}("");
            require(sent, "Transfer failed");
        } else {
            user.amountToken[_tokenAddress].amount -= _amount;
            bool sent = IERC20(_tokenAddress).transfer(msg.sender, _amount);
            require(sent, "Transfer failed");
        }

        emit Withdraw(msg.sender, _amount);
    }

    // Collateral tokens from STAKING.
    function collateral(address _tokenAddress, uint256 _amount) external {
        //PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require(
            user.amountToken[_tokenAddress].amount >= _amount,
            "Collateral: not good"
        );

        if (_tokenAddress == address(0)) {
            require(msg.value == _amount, "not enough");
            userTokenBalance[msg.sender][_tokenAddress] += msg.value;
        } else {
            require(
                supportTokens[_tokenAddress],
                "This token is not supported"
            );
            userTokenBalance[msg.sender][_tokenAddress] += _amount;
            bool sent = IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            require(sent, "Transfer failed");
        }
    }
}
