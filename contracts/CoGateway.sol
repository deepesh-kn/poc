pragma solidity >=0.5.0 <0.6.0;

import "./MasterCopyNonUpgradable.sol";

contract CoGateway is MasterCopyNonUpgradable{

    address public gatewayAddress;

    function setup(address _gateway) external {
        gatewayAddress = _gateway;
    }
}
