pragma solidity >=0.5.0 <0.6.0;

import "./Anchor.sol";
import "./Core.sol";
import "./DummyContract.sol";
import "./Genesis.sol";

contract Axiom {

    address[] public updatedValidators;
    uint256[] public updatedReputation;
    address public consensus;
    address public techGov;
    address public core;
    address public anchor;
    uint256 public gasTarget;
    bytes public rlpBlockHeader;

    Genesis public genesis;

    constructor(uint256 _gasTarget) public {
        gasTarget = _gasTarget;
        techGov = msg.sender;
        consensus = address(new DummyContract());
    }

    function newMetachain(
        bytes calldata _rlpBlockHeader
    )
    external
    {
        core = address(new Core());
        anchor = address(new Anchor());
        rlpBlockHeader = _rlpBlockHeader;
    }

    function join(uint256 _reputation) external {
        updatedValidators.push(msg.sender);
        updatedReputation.push(_reputation);
    }

    function quorumReached() external {

        genesis = new Genesis();
        genesis.initialize(
            bytes20(core),
            consensus,
            techGov,
            updatedValidators,
            updatedReputation,
            gasTarget,
            rlpBlockHeader
        );
    }
}
