# Arquitectura sugerida (MVP)

## 1) InstitutionRegistry — Control de Emisores
**Responsabilidad:** Llevar registro de qué direcciones pueden emitir certificados.  

**Funciones principales:**
- `grantIssuer(address account)` — **solo Admin**.
- `revokeIssuer(address account)` — **solo Admin**.
- `isIssuer(address account) → bool` — vista pública.
- `getAllIssuers() → address[]` *(opcional; mejor usar eventos + indexador off-chain).*

**Eventos:** (Contemplados por OpenZeppelin pero igual)
- `IssuerGranted(address issuer)` 
- `IssuerRevoked(address issuer)`

> Podés implementar el rol de Admin usando `AccessControl` (con `DEFAULT_ADMIN_ROLE`).  
> El contrato `SoulboundCertificate` consultará a este para validar emisores.

---

### 2) SoulboundCertificate — Implementación del SBT

**Objetivo**:
El contrato *SoulboundCertificate* implementa un sistema de *certificados intransferibles* (Soulbound Tokens - SBT) basados en el estándar ERC-721.  
El objetivo es permitir que instituciones educativas autorizadas emitan y revoquen certificados académicos directamente en la blockchain.

**Responsabilidades**
- **Emitir certificados:** Crear un token único para cada certificado, asignado a un estudiante.
- **Guardar datos del certificado:** Mantener información como emisor, titular, fecha de emisión y metadatos.
- **Revocar certificados:** Permitir que solo la misma institución emisora pueda revocar un certificado ya emitido.
- **Bloquear transferencias:** Los certificados son permanentes y no pueden ser transferidos ni delegados.

**Funciones principales**
- `issueCertificate(address holder, string metadataURI)`  
  Permite a un emisor autorizado crear un nuevo certificado para un estudiante.  
  El `tokenId` se genera automáticamente de forma incremental.
  
- `revoke(uint256 tokenId)`  
  Revoca un certificado previamente emitido. Solo puede hacerlo la institución que lo emitió.

- `getCertificate(uint256 tokenId)`  
  Devuelve toda la información registrada sobre un certificado: emisor, titular, fecha, estado y metadatos.

- `locked(uint256 tokenId)`  
  Indica que el certificado está permanentemente bloqueado, siguiendo el estándar **EIP-5192** para SBT.

**Restricciones de transferencia:**
Se sobrescribieron las funciones de ERC-721 relacionadas con transferencias y aprobaciones para forzar un `revert`.  
De esta manera:
- No se puede transferir (`transferFrom`, `safeTransferFrom`).
- No se puede aprobar a otra cuenta (`approve`, `setApprovalForAll`).

**Eventos:**
El contrato emite eventos que permiten hacer un seguimiento histórico:
- `Issued(tokenId, issuer, holder)` → cuando se emite un certificado.
- `Revoked(tokenId, issuer)` → cuando una institución revoca un certificado.
- `Locked(tokenId)` → cumple con EIP-5192 y señala que el token es soulbound.

**Conclusión:**
Con este contrato se logra:
- Un sistema transparente de certificados académicos.
- Seguridad al restringir la emisión a instituciones validadas en el **InstitutionRegistry**.
- Inmutabilidad en la titularidad (los certificados no se pueden transferir).
- Compatibilidad con el ecosistema de tokens gracias al uso de ERC-721 y EIP-5192.


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
