// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @dev Interfaz mínima para consultar el registry de emisores
interface IInstitutionRegistry {
    function isIssuer(address account) external view returns (bool);
}

/// @dev Interfaz mínima EIP-5192 (SBT): sólo Locked + locked()
interface IERC5192 {
    /// @notice Emitido cuando un token queda bloqueado (no transferible).
    event Locked(uint256 tokenId);

    /// @notice Siempre true para SBT.
    function locked(uint256 tokenId) external view returns (bool);
}

contract SoulboundCertificate is ERC721, IERC5192 {

/* --------------------------------- Errores -------------------------------- */
    error ZeroAddress();
    error NotIssuer();       // msg.sender no es emisor autorizado
    error NotIssuerOf();     // msg.sender no es quien emitió ese token
    error NonexistentToken();
    error AlreadyRevoked();
    error NonTransferable(); // transfer/safeTransfer prohibidos
    error ApprovalsDisabled();

/* --------------------------------- Eventos -------------------------------- */
    event Issued(uint256 indexed tokenId, address indexed issuer, address indexed holder);
    event Revoked(uint256 indexed tokenId, address indexed issuer);

/* ------------------------------- Estructuras ------------------------------ */
    /// @notice Estructura con todos los datos del certificado.
    struct Certificate {
        address issuer;
        address holder;
        uint64  issuedAt;
        bool    revoked;
        string  metadataURI;
    }

/* --------------------------------- Estado -------------------------------- */
    IInstitutionRegistry public immutable registry;
    uint256 private _nextId = 1;

    mapping(uint256 => Certificate) private _certs;
    mapping(uint256 => address) private _issuerOf;
    mapping(uint256 => string) private _tokenURIs;

/* --------------------------------- Constructor --------------------------------- */
    constructor(address registry_) ERC721("SoulboundCertificate", "SBT") {
        if (registry_ == address(0)) revert ZeroAddress();
        registry = IInstitutionRegistry(registry_);
    }

/* --------------------------------- Modifiers ------------------------------- */
    modifier onlyIssuer() {
        if (!registry.isIssuer(msg.sender)) revert NotIssuer();
        _;
    }

/* --------------------------------- Funciones públicas --------------------------------- */

    function issueCertificate(address holder, string calldata metadataURI_)
        external
        onlyIssuer
        returns (uint256 tokenId)
    {
        if (holder == address(0)) revert ZeroAddress();

        tokenId = _nextId;
        unchecked { _nextId = tokenId + 1; } // micro-opt de gas

        _safeMint(holder, tokenId);

        _issuerOf[tokenId] = msg.sender;
        _tokenURIs[tokenId] = metadataURI_;
        _certs[tokenId] = Certificate({
            issuer: msg.sender,
            holder: holder,
            issuedAt: uint64(block.timestamp),
            revoked: false,
            metadataURI: metadataURI_
        });

        emit Issued(tokenId, msg.sender, holder);
        emit Locked(tokenId); // EIP-5192
    }

    function revoke(uint256 tokenId) external {
        address issuer = _issuerOf[tokenId];
        if (issuer == address(0)) revert NonexistentToken();
        if (msg.sender != issuer) revert NotIssuerOf();

        Certificate storage c = _certs[tokenId];
        if (c.revoked) revert AlreadyRevoked();

        c.revoked = true;
        emit Revoked(tokenId, issuer);
    }

    function getCertificate(uint256 tokenId) external view returns (Certificate memory) {
        if (_ownerOf(tokenId) == address(0)) revert NonexistentToken();
        return _certs[tokenId];
    }

    function locked(uint256 tokenId) external view returns (bool) {
        if (_ownerOf(tokenId) == address(0)) revert NonexistentToken();
        return true;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) revert NonexistentToken();
        return _tokenURIs[tokenId];
    }

/* --------------------------------- Bloqueo de transferencias --------------------------------- */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert NonTransferable();
        }
        return super._update(to, tokenId, auth);
    }

    function approve(address, uint256) public pure override {
        revert ApprovalsDisabled();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert ApprovalsDisabled();
    }

    function transferFrom(address, address, uint256) public pure override {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
        revert NonTransferable();
    }

/* --------------------------------- Fallback / Receive --------------------------------- */
    receive() external payable { revert(); }
    fallback() external payable { revert(); }

/* --------------------------------- Soporte de interfaces --------------------------------- */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC5192).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
