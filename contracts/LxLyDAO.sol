// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "./polygonZKEVMContracts/interfaces/IBridgeMessageReceiver.sol";
import "./polygonZKEVMContracts/interfaces/IPolygonZkEVMBridge.sol";


contract LxLyDAO is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, Ownable {

    IPolygonZkEVMBridge public immutable polygonZkEVMBridge;
    address public l1Receiver;
    constructor(IVotes _token, IPolygonZkEVMBridge _polygonZkEVMBridge)
        Governor("LxLyDAO")
        GovernorSettings(0 /* 0 block */, 30 /* 6 minutes */, 0)
        GovernorVotes(_token)
    {
        polygonZkEVMBridge = _polygonZkEVMBridge;
    }

    function quorum(uint256 blockNumber) public pure override returns (uint256) {
        return 1e18;
    }

    // The following functions are overrides required by Solidity.

    function votingDelay() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    /**
     * @notice Send a message to the other network
     * @param destinationNetwork Network destination
     * @param forceUpdateGlobalExitRoot Indicates if the global exit root is updated or not
     */
    function bridgeAction(
        uint32 destinationNetwork,
        bool forceUpdateGlobalExitRoot,
        uint256 payload
    ) public onlyOwner {
        bytes memory data = abi.encode(payload);

        // Bridge ping message
        polygonZkEVMBridge.bridgeMessage(
            destinationNetwork,
            l1Receiver,
            forceUpdateGlobalExitRoot,
            data
        );

        emit PingMessage(pingValue);
    }
}
