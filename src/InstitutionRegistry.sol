//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.24;


// OpenZeppelin ^5.x
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title InstitutionRegistry
 * @notice Maintains a registry of accounts authorized to issue certificates. Only the admin can grant or revoke these permissions.
 */

contract InstitutionRegistry is AccessControl {
   
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");


}