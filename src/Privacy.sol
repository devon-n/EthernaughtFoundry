// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {

  // 8 bit = 1 Byte
  bool public locked = true; // Slot 0 (1 bit)
  uint256 public ID = block.timestamp; // Slot 1 (32 bytes)
  uint8 private flattening = 10; // Slot 2 (1 bytes)
  uint8 private denomination = 255; // Slot 2 (1 bytes)
  uint16 private awkwardness = uint16(block.timestamp); // Slot 2 (2 bytes)
  bytes32[3] private data; // Slot 3-5 (32 Bytes * 3)

  constructor(bytes32[3] memory _data) {
    data = _data;
  }

  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}