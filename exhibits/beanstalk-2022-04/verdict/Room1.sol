// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";
import {CellEscrow} from "dan/CellEscrow.sol";
import {IssuanceModule} from "dan/IssuanceModule.sol";
import {ClaimDisputeModule} from "dan/ClaimDisputeModule.sol";
import {SpecGapModule} from "dan/SpecGapModule.sol";
import {SpecArbiterModule} from "dan/SpecArbiterModule.sol";
import {IntegrityReviewModule} from "dan/IntegrityReviewModule.sol";
import {StructuralUpgradeModule} from "dan/StructuralUpgradeModule.sol";
import {FmeaRegistry} from "dan/FmeaRegistry.sol";
import {AssignmentModule} from "dan/AssignmentModule.sol";
import {IAssignmentModule} from "dan/IAssignmentModule.sol";

/// Room 1: the verdict.
///
/// What the test and the script share. The hull is stood up the way its own suite
/// stands it up, a row is filed against the Beanstalk diamond's code hash with no
/// deployed address behind it, and the row is settled so that dan-check can find
/// it by that hash.
///
/// Who calls what is deliberately not in here. The test pranks and the script
/// broadcasts, so each caller sets its own sender around these calls.
library Room1 {
    /// The same numbers Fork.t.sol proves against the chain. Pulled with commands,
    /// written beside them in PROVENANCE.md; never typed from a description.
    uint256 internal constant FORK_BLOCK = 14_595_905;
    address internal constant BEANSTALK = 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5;
    bytes32 internal constant BEANSTALK_CODEHASH =
        0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870;
    uint256 internal constant BEANSTALK_CODE_LENGTH = 5547;

    /// The spec the row names. Its hash is read from the file at run time, never
    /// pasted in.
    string internal constant SPEC_PATH = "exhibits/beanstalk-2022-04/spec/governance-v0.json";

    /// Tool ids are the code hashes of the tools that read the spec and produced
    /// the verdict. The museum has no such tools: the spec was read by a person and
    /// the verdict is the finding written in the room. These labels stand in their
    /// place and say so.
    bytes32 internal constant SPEC_TOOL = keccak256("museum/beanstalk-2022-04: spec read by a person");
    bytes32 internal constant VERDICT_TOOL = keccak256("museum/beanstalk-2022-04: verdict written by a person");

    /// The spec validator recorded no errors against the spec.
    bytes32 internal constant SPEC_ERRORS = keccak256("");

    /// Bounty in the cell's own token, minted at genesis to the party filing the row.
    uint256 internal constant BOUNTY = 40 ether;
    uint256 internal constant GENESIS = 2_000 ether;

    /// The hull: the cell, its token and escrow, and the modules it is wired to.
    struct Hull {
        CellToken token;
        CellEscrow escrow;
        AuditCell cell;
        IssuanceModule issuance;
        ClaimDisputeModule claimModule;
        SpecGapModule specGapModule;
        SpecArbiterModule specArbiterModule;
        IntegrityReviewModule integrityReviewModule;
        StructuralUpgradeModule structuralUpgradeModule;
        FmeaRegistry fmeaRegistry;
        AssignmentModule assignmentModule;
    }

    /// The result root a verdict tool would produce. Here it binds the verdict to
    /// the code hash and the spec hash, so the same pair yields the same root.
    function resultRoot(bytes32 specHash) internal pure returns (bytes32) {
        return keccak256(abi.encode("PASS", BEANSTALK_CODEHASH, specHash));
    }

    function declared() internal pure returns (bytes32[] memory tools) {
        tools = new bytes32[](1);
        tools[0] = VERDICT_TOOL;
    }

    /// Stand the hull up. `admin` administers every piece and must be the sender:
    /// the cell and the token take msg.sender as admin in their constructors, the
    /// modules take the address they are given.
    ///
    /// The wiring is the cell's own, copied step for step from
    /// cell/test/helpers/CellTestDeploy.sol (deploy → deployWithoutAssignment,
    /// then attachMinter and registerDefaultTools). It is copied rather than
    /// imported because that helper reaches its contracts through `../../`, and
    /// from outside the cell tree the compiler sees the hull twice, under two
    /// spellings of one path, and cannot link it. If the helper changes, this
    /// must change with it; diff the two.
    ///
    /// `protocol` is the party that will file the row and is funded here, at
    /// genesis, before the minter is attached (G-02).
    function stand(address admin, address protocol) internal returns (Hull memory h) {
        h.token = new CellToken();
        h.cell = new AuditCell(address(h.token));
        h.escrow = new CellEscrow(address(h.token));
        h.issuance = new IssuanceModule(admin);
        h.claimModule = new ClaimDisputeModule(admin);
        h.specGapModule = new SpecGapModule(admin);
        h.specArbiterModule = new SpecArbiterModule(admin);
        h.integrityReviewModule = new IntegrityReviewModule(admin);
        h.structuralUpgradeModule = new StructuralUpgradeModule(admin);
        h.fmeaRegistry = new FmeaRegistry(admin);
        h.issuance.wire(address(h.cell), address(h.token), address(h.escrow));
        h.claimModule.wire(address(h.cell));
        h.fmeaRegistry.wireClaimModule(address(h.claimModule));
        h.claimModule.wireFmeaRegistry(address(h.fmeaRegistry));
        h.specGapModule.wire(address(h.cell));
        h.specArbiterModule.wire(address(h.cell));
        h.integrityReviewModule.wire(address(h.cell), address(h.specArbiterModule));
        h.structuralUpgradeModule.wire(address(h.cell), address(h.issuance));
        h.issuance.setStructuralModule(address(h.structuralUpgradeModule));
        h.escrow.setNetwork(address(h.cell));
        h.escrow.setIssuanceModule(address(h.issuance));
        h.escrow.setStructuralUpgradeModule(address(h.structuralUpgradeModule));
        h.escrow.setIntegrityReviewModule(address(h.integrityReviewModule));
        h.cell.setTreasuryEscrow(address(h.escrow));
        h.cell.setIssuanceModule(address(h.issuance));
        h.cell.setDisputeModule(0, address(h.claimModule));
        h.cell.setDisputeModule(1, address(h.specGapModule));
        h.cell.setDisputeModule(2, address(h.specArbiterModule));
        h.cell.setDisputeModule(3, address(h.integrityReviewModule));
        h.cell.setDisputeModule(4, address(h.structuralUpgradeModule));

        h.assignmentModule = new AssignmentModule(admin);
        h.assignmentModule.wire(address(h.cell));
        h.cell.setAssignmentModule(address(h.assignmentModule));
        h.assignmentModule.setAssignmentMode(IAssignmentModule.AssignmentMode.QueueFifo);

        h.token.genesisMint(protocol, GENESIS);
        h.token.setMinter(address(h.issuance));
        h.cell.registerTool(SPEC_TOOL, true);
        h.cell.registerTool(VERDICT_TOOL, false);
    }

    /// File the row. Called as `protocol`. A bare hash, no deployed address: the
    /// cell is asked about code, not about a place.
    function file(AuditCell cell, CellToken token, bytes32 codehash, bytes32 specHash)
        internal
        returns (uint256 id)
    {
        token.approve(address(cell), BOUNTY);
        id = cell.submitArtifactAudit(codehash, address(0), specHash, SPEC_TOOL, SPEC_ERRORS, BOUNTY, declared(), 0, 0);
    }
}
