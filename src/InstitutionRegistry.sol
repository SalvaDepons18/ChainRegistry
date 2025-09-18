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

    // Custom errors cheaper than strings (GAS)
    error ZeroAddress();
    error AlreadyIssuer();
    error NotAnIssuer();

    constructor(address initialAdmin){
        if(initialAdmin == address(0)) revert ZeroAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    }

    function grantIssuer(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        if (hasRole(ISSUER_ROLE, account)) revert AlreadyIssuer();
        _grantRole(ISSUER_ROLE, account);
    }

    function revokeIssuer(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        if(!hasRole(ISSUER_ROLE,account)) revert NotAnIssuer();
        _revokeRole(ISSUER_ROLE,account);
    }

    function isIssuer(address account) external view returns (bool){
        return hasRole(ISSUER_ROLE,account);
    }

}