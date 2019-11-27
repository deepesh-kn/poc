
const BN = require('bn.js');
const genesisTemplate = require( "./genesisTemplate.json" );

function createGenesis(chainId, data, sealer, validators) {
  genesisTemplate.timestamp = getTimeStamp();

  validators.forEach(
    address => {
      genesisTemplate.alloc[remove0x(address)] = { balance: '0x295be96e640669720000000' };
    }
  );
  genesisTemplate.config.chainId = '2';
  genesisTemplate.extraData = `0x0000000000000000000000000000000000000000000000000000000000000000${remove0x(sealer)}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000`;

  genesisTemplate.alloc['00000000000000000000000000000000000fffff'] = { balance: '0', code: data };
  genesisTemplate.alloc[remove0x(sealer)] = { balance: '0x295be96e640669720000000' };
  console.log('genesisTemplate', JSON.stringify(genesisTemplate));
}

function remove0x(input) {
  if (input.substring(0, 2) === '0x') {
    input = input.substring(2);
  }
  return input;
}
function getTimeStamp() {
  const timestampInMilliseconds = Date.now();
  // 1000 milliseconds per second:
  const unixTimestamp = Math.floor(timestampInMilliseconds / 1000);
  const hexTimestamp = unixTimestamp.toString(16);

  return `0x${hexTimestamp}`;
}
module.exports = {
  createGenesis
};
