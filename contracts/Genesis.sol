pragma solidity >=0.5.0 <0.6.0;

import "./MasterCopyNonUpgradable.sol";

contract Genesis is MasterCopyNonUpgradable {

    /* Constants */

    uint256 constant public chainIdOffset = 0x20;
    uint256 constant public consensusGatewayOffset = 0x40;
    uint256 constant public techGovOffset = 0x60;
    uint256 constant public gasTargetOffset = 0x80;
    uint256 constant public reputationOffset = 0xa0;
    uint256 constant public validatorOffset = 0xc0;
    uint256 constant public blockHeaderOffset = 0xe0;


    /* variables */

    bytes public data;


    /* Modifiers */

    modifier notInitialized()
    {
        require(
            data.length == 0,
            "Genesis contract is already initialized."
        );

        _;
    }


    /* External functions */

    function initialize(
        bytes20 _chainId,
        address _consensusGateway,
        address _techGov,
        address[] calldata _updatedValidators,
        uint256[] calldata _updatedReputation,
        uint256 _gasTarget,
        bytes calldata _startBlockHeader
    )
    notInitialized
    external
    {
        data = abi.encode(
            _chainId,
            _consensusGateway,
            _techGov,
            _gasTarget,
        //_updatedReputation.length,
            _updatedReputation,
        //_updatedValidators.length,
            _updatedValidators,
            _startBlockHeader
        );
    }

    function initializeFromAddress (
        address _dataAddress
    )
    notInitialized
    external
    {
        bytes memory o_code;
        assembly {
        // retrieve the size of the code, this needs assembly
            let size := extcodesize(_dataAddress)
        // allocate output byte array - this could also be done without assembly
        // by using o_code = new bytes(size)
            o_code := mload(0x40)
        // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        // store length in memory
            mstore(o_code, size)
        // actually retrieve the code, this needs assembly
            extcodecopy(_dataAddress, add(o_code, 0x20), 0, size)
        }
        data = o_code;
    }

    function chainId ()
    external
    view
    returns (bytes20 chainId_)
    {
        bytes memory _data = data;
        assembly {
            chainId_ := mload(add(_data, chainIdOffset))
        }
    }

    function consensusGateway()
    external
    view
    returns (address consensusGateway_)
    {
        bytes memory _data = data;
        assembly {
            consensusGateway_ := mload(add(_data, consensusGatewayOffset))
        }
    }

    function techGov()
    external
    view
    returns (address techGov_)
    {
        bytes memory _data = data;
        assembly {
            techGov_ := mload(add(_data, techGovOffset))
        }
    }

    function gasTarget()
    external
    view
    returns (uint256 gasTarget_)
    {
        bytes memory _data = data;
        assembly {
            gasTarget_ := mload(add(_data, gasTargetOffset))
        }
    }

    function reputations()
    external
    view
    returns (
        uint256[] memory reputations_
    )
    {
        bytes memory _data = data;
        uint256 rCount;
        uint256 readIndex;
        assembly {
            readIndex := mload(add(_data, reputationOffset))
            readIndex := add(readIndex, 0x20)
            rCount := mload(add(_data, readIndex))
        }
        reputations_ = new uint256[](rCount);
        uint256 writeIndex = 0x0;
        for(uint256 i=0; i < rCount; i += 1) {
            readIndex += 0x20;
            writeIndex += 0x20;
            assembly {
                mstore(add(reputations_, writeIndex), mload(add(_data, readIndex)))
            }
        }
    }

    function validators()
    external
    view
    returns (address[] memory validators_)
    {
        bytes memory _data = data;
        uint256 vCount;
        uint256 readIndex;
        assembly {
            readIndex := mload(add(_data, validatorOffset))
            readIndex := add(readIndex, 0x20)
            vCount := mload(add(_data, readIndex))
        }
        validators_ = new address[](vCount);
        uint256 writeIndex = 0x0;
        for(uint256 i=0; i < vCount; i += 1) {
            readIndex += 0x20;
            writeIndex += 0x20;
            assembly {
                mstore(add(validators_, writeIndex), mload(add(_data, readIndex)))
            }
        }
    }

    function blockHeader()
    external
    view
    returns (
        bytes memory blockHeader_,
        uint256 readIndex_,
        uint256 length_
    )
    {
        bytes memory _data = data;
        uint256 offset = blockHeaderOffset;
        uint256 readIndex;
        uint256 length;
        assembly {
            readIndex := mload(add(_data, offset))
            readIndex := add(readIndex, 0x20)
            length := mload(add(_data, readIndex))
        }
        blockHeader_ = slice(_data, readIndex, length);
        readIndex_ = readIndex;
        length_ = length;
    }


    /* Internal functions */

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
    internal
    pure
    returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
                tempBytes := mload(0x40)

            // The first word of the slice result is potentially a partial
            // word read from the original array. To read it, we calculate
            // the length of that partial word and start copying that many
            // bytes into the array. The first word we copy will start with
            // data we don't care about, but the last `lengthmod` bytes will
            // land at the beginning of the contents of the new array. When
            // we're done copying, we overwrite the full first word with
            // the actual length of the slice.
                let lengthmod := and(_length, 31)

            // The multiplication in the next line is necessary
            // because when slicing multiples of 32 bytes (lengthmod == 0)
            // the following copy loop was copying the origin's length
            // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                // The multiplication in the next line has the same exact purpose
                // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

            //update free-memory pointer
            //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}





// function encode(bytes calldata _startBlockHeader) external {
//     bytes20 chainId_ = bytes20(0xe7551fE9960080614BA5662c6178D7373eDB076B);
//     address consensusGateway_ = address(0x0000000000000000000000000000000000000011);
//     address techGov_ = address(0x0000000000000000000000000000000000000022);
//     address payable[6] memory updatedValidators_ = [0x0000000000000000000000000000000000000033,0x0000000000000000000000000000000000000044,0x0000000000000000000000000000000000000055,0x0000000000000000000000000000000000000066,0x0000000000000000000000000000000000000077, 0x0000000000000000000000000000000000000099];
//     uint256[4] memory updatedReputation_ = [uint256(21), uint256(3),uint256(113),uint256(74)];
//     uint256 gasTarget_ = uint256(30000);
//     //bytes memory startBlockHeader_ = 0xd0778b54f7faf7b0a5ddade005ea6a37e7fae5706eb7b9d7c8fc532b2988794c692a70D2e424a56D2C6C27aA97D1a86395877b3ABCdef1234567890;

//     data = abi.encode(
//          chainId_,
//          consensusGateway_,
//          techGov_,
//          gasTarget_,
//          updatedReputation_.length,
//          updatedReputation_,
//          updatedValidators_.length,
//          updatedValidators_,
//          _startBlockHeader
//     );
// }

// [21,3,113,74]
// "0x0000000000000000000000000000000000000033","0x0000000000000000000000000000000000000044","0x0000000000000000000000000000000000000055","0x0000000000000000000000000000000000000066","0x0000000000000000000000000000000000000077", "0x0000000000000000000000000000000000000099"




// function reputationCount()
//         public
//         view
//         returns (uint256 reputationCount_)
//     {
//       bytes memory _data = data;
//       uint256 startIndex;
//       assembly {
//             startIndex := mload(add(_data, reputationOffset))
//             startIndex := add(startIndex, 0x20)
//             reputationCount_ := mload(add(_data, startIndex))
//         }
//     }

//     function validatorsCount()
//         public
//         view
//         returns (uint256 numberOfValidators_)
//     {
//         bytes memory _data = data;
//         uint256 startIndex;
//         assembly {
//             startIndex := mload(add(_data, validatorOffset))
//             startIndex := add(startIndex, 0x20)
//             numberOfValidators_ := mload(add(_data, startIndex))
//         }
//     }
