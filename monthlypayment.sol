pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MonthlyPayment {
    using SafeMath for uint256;

    address public owner;
    address public recipient;
    uint256 public amount;
    uint256 public duration;
    uint256 public lastPaymentTime;

    IERC20 public usdt;

    mapping(address => bool) public authorizedUsers;
    uint256 public authorizedAmount;

    constructor(address _usdtAddress, address _recipient, uint256 _amount, uint256 _duration, address[] memory _authorizedUsers, uint256 _authorizedAmount) {
        owner = msg.sender;
        usdt = IERC20(_usdtAddress);
        recipient = _recipient;
        amount = _amount;
        duration = _duration;
        lastPaymentTime = block.timestamp;
        
        // Agregar usuarios autorizados
        for (uint256 i = 0; i < _authorizedUsers.length; i++) {
            authorizedUsers[_authorizedUsers[i]] = true;
        }
        
        authorizedAmount = _authorizedAmount;
    }

    function transferUSDT() public {
        require(authorizedUsers[msg.sender] == true, "You are not authorized to execute this function.");
        require(block.timestamp >= lastPaymentTime.add(duration), "Monthly duration has not passed yet.");

        uint256 balance = usdt.balanceOf(address(this));
        require(balance >= authorizedAmount, "Insufficient balance.");

        lastPaymentTime = block.timestamp;
        usdt.transfer(msg.sender, authorizedAmount);
    }

    function withdrawUSDT() public {
        require(msg.sender == owner, "Only the owner can execute this function.");

        uint256 balance = usdt.balanceOf(address(this));
        require(balance > 0, "Contract has no balance.");

        usdt.transfer(owner, balance);
    }
}