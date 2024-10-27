// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PyPouch.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract PyPouchFactory {
    address public immutable implementation;

    event PyPouchCreated(address indexed owner, address pyPouchAddress);

    constructor() {
        implementation = address(new PyPouch());
    }

    function createPyPouch(address _pyusdToken, address _aPYUSD, address _aavePool) external returns (address) {
        address clone = Clones.cloneDeterministic(implementation, _addressToBytes32(msg.sender));
        PyPouch(clone).initialize(msg.sender, _pyusdToken, _aPYUSD, _aavePool);

        emit PyPouchCreated(msg.sender, clone);

        return clone;
    }

    function getPyPouchAddress(address owner) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, _addressToBytes32(owner));
    }


    function _addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

}