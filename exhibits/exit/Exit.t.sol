// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// The exit hands the visitor one command, and the command is only worth handing
/// over if it is the tool the rooms were read with. The two files under dan-check/
/// are copied byte for byte from the network repository's committed blobs; this test
/// re-hashes them and fails if a single byte has moved.
///
/// It runs offline, like Room 1's provenance test.
contract ExitTest is Test {
    string internal constant DIR = "exhibits/exit/dan-check/";

    function _sha256Of(string memory name) internal view returns (bytes32) {
        return sha256(vm.readFileBinary(string.concat(DIR, name)));
    }

    /// The hashes are the ones README.md records: dan-check.mjs as committed at
    /// network 54d3765 (the PC-132 cure, its oracle 65 passed, 0 failed), and
    /// keccak256.mjs as committed at network 9c54690.
    function test_theToolIsTheNetworksTool() public view {
        assertEq(
            _sha256Of("dan-check.mjs"),
            0xf009360f507b50e7d2703c6251abf061b94905b15430486a410bb1f84a696d85,
            "dan-check.mjs has changed"
        );
        assertEq(
            _sha256Of("keccak256.mjs"),
            0x195c078551e580b099ccdc49a15212373d3eb31f87649aded1b8d3dc1922824b,
            "keccak256.mjs has changed"
        );
    }
}
