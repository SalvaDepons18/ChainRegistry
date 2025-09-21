# Arquitectura sugerida (MVP)

## 1) InstitutionRegistry — Control de Emisores
**Responsabilidad:** Llevar registro de qué direcciones pueden emitir certificados.  

**Funciones principales:**
- `grantIssuer(address account)` — **solo Admin**.
- `revokeIssuer(address account)` — **solo Admin**.
- `isIssuer(address account) → bool` — vista pública.
- `getAllIssuers() → address[]` *(opcional; mejor usar eventos + indexador off-chain).*

**Eventos:**
- `IssuerGranted(address issuer)`
- `IssuerRevoked(address issuer)`

> Podés implementar el rol de Admin usando `AccessControl` (con `DEFAULT_ADMIN_ROLE`).  
> El contrato `SoulboundCertificate` consultará a este para validar emisores.

---

## 2) SoulboundCertificate — El SBT en Sí
**Responsabilidad:** Emitir, guardar y revocar certificados.  

**Funciones principales:**
- `issueCertificate(address holder, …meta…) → uint256 tokenId`  
  **solo emisor autorizado** (consulta a `InstitutionRegistry`).
- `revoke(uint256 tokenId)` — solo la **misma institución** que lo emitió.
- `getCertificate(uint256 tokenId) → Certificate` — vista.
- `locked(uint256 tokenId) → bool` — siempre `true` (EIP-5192 minimal, opcional).

**Restricciones de transferencia:**  
Sobrescribir y forzar `revert` en:
- `transferFrom`
- `safeTransferFrom`
- `approve`
- `setApprovalForAll`

**Eventos:**
- `Issued(uint256 tokenId, address issuer, address holder)`
- `Revoked(uint256 tokenId, address issuer)`

> Este contrato puede heredar de `ERC721` (OpenZeppelin).  
> Generar `tokenId` de forma autoincremental.

---

## 3) VerifierPortal (Opcional — Solo Lectura)
**Responsabilidad:** Facilitar consultas para terceros (lectura sin permisos).  

**Funciones de ejemplo:**
- `verify(uint256 tokenId) → (issuer, holder, revoked, cid, contentHash, issueDate)`
- `holderCertificates(address holder, uint256 offset, uint256 limit) → uint256[]`
- `issuerCertificates(address issuer, uint256 offset, uint256 limit) → uint256[]`

> Útil si querés una API de lectura cómoda sin exponer la estructura interna.

---

## 4) InstitutionMetadata (Opcional)
**Responsabilidad:** Guardar metadatos de instituciones.  
Ejemplo de datos: nombre, `metadataCID`, estado.  

> Solo vale la pena si querés algo más que un booleano de “es emisor”.  
> Si no, lo podés mantener fuera de la blockchain o dentro de `InstitutionRegistry`.

---

## Índices y Listados (Importante)
- **Evitar** `ERC721Enumerable` en mainnet por costo de gas.
- **Alternativas:**
  - Usar **The Graph** u otro indexador off-chain (lo más profesional).
  - Mantener mappings ligeros y paginables:
    ```solidity
    mapping(address => uint256[]) byHolder;
    mapping(address => uint256[]) byIssuer;
    ```
  - Exponer funciones **paginadas** (`offset`, `limit`).
  - No borrar IDs al revocar → **marcar estado** y filtrar en lectura.

> Guardar una lista de certificados dentro de un `struct Student` es conceptualmente lo mismo que `byHolder[wallet]`.  
> Preferí el mapping directo: es más desacoplado y simple.
