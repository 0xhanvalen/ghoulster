// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Ghoulster {

    struct GhoulsterPair {
        address ghoulA;
        address ghoulB;
    }

    // mapping of pairs 
    mapping (address => GhoulsterPair) public ghoulPairs;

    // track if users have deposited their ghift (ghoul gift)
    mapping (address => bool) public hasDeposited;
    
    // track what ghoul someone deposited
    mapping (address => uint256) public depositedGhouls;
    
    IERC721 ghoulContract = IERC721(0xeF1a89cbfAbE59397FfdA11Fc5DF293E9bC5Db90);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function createGhoulPair(address _ghoulA, address _ghoulB) internal {
        GhoulsterPair memory newGhoulPair = GhoulsterPair(_ghoulA, _ghoulB);
        ghoulPairs[_ghoulA] = newGhoulPair;
        ghoulPairs[_ghoulB] = newGhoulPair;
    }

    function addGhoulPairs(address[] calldata ghouls) public {
        require(msg.sender == owner, "Only the owner can add ghoul pairs");
        for (uint i = 0; i < ghouls.length; i += 2) {
            createGhoulPair(ghouls[i], ghouls[i+1]);
        }
    }

    // allow users to deposit tokens to escrow
    function deposit(uint256 ghoulID) public {
        require(!hasDeposited[msg.sender], "You have already deposited your ghift");
        ghoulContract.transferFrom(msg.sender, address(this), ghoulID);
        depositedGhouls[msg.sender] = ghoulID;
        hasDeposited[msg.sender] = true;
    }

    // allow users to recover their tokens
    function recover() public {
        require(hasDeposited[msg.sender], "You have not deposited your ghift");
        ghoulContract.transferFrom(address(this), msg.sender, depositedGhouls[msg.sender]);
        hasDeposited[msg.sender] = false;
    }

    // allow users to withdraw their ghift 
    function withdraw() public {
        require(hasDeposited[msg.sender], "You have not deposited your ghift");
        // get ghoul pair
        GhoulsterPair memory ghoulPair = ghoulPairs[msg.sender];
        // get other ghoul
        address otherGhoul = ghoulPair.ghoulA == msg.sender ? ghoulPair.ghoulB : ghoulPair.ghoulA;
        // transfer ghoul to other ghoul
        ghoulContract.transferFrom(address(this), msg.sender, depositedGhouls[otherGhoul]);
    }
}
