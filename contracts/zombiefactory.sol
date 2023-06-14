pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";

contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);
    
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days; // 1 day

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime; // cooldown period
        // wins and losses
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;


    function _createZombie(string memory _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // msg.sender is a global variable that refers to an address
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // avoid to create unlimited zombie for each accounts
        require(ownerZombieCount[msg.sender] == 0); // throws an error if not true
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
