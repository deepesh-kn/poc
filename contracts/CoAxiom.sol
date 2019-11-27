pragma solidity >=0.5.0 <0.6.0;

import "./Genesis.sol";
import "./CoGateway.sol";
import "./CoGatewayProxy.sol";

contract CoAxiom {

    address constant public genesisData = 0x00000000000000000000000000000000000fFFFf;
    address payable constant public coGatewayAddress = 0x00000000000000000000000000000000000dDDdd;
    Genesis public genesis;

    function initialize() external {
        genesis = new Genesis();
        genesis.initializeFromAddress(genesisData);

        CoGatewayProxy coGatewayProxy = CoGatewayProxy(coGatewayAddress);
        coGatewayProxy.initialize();

        CoGateway coGateway = CoGateway(coGatewayAddress);
        address gatewayAddress = genesis.consensusGateway();
        coGateway.setup(gatewayAddress);

    }

}
