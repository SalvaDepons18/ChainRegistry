# 📚 Guía para Proyecto Blockchain — Certificados Soulbound

Esta guía define paso a paso cómo diseñar, implementar y desplegar un sistema de certificados académicos en blockchain, siguiendo buenas prácticas de desarrollo, seguridad y documentación.

---

## 1) Definir Alcance y Requisitos
- **Objetivo:** Una oración clara que resuma el propósito del sistema.
- **Roles:**
  - **Admin**
  - **Emisor (Institución)**
  - **Estudiante (Holder)**
  - **Verificador**
- **Casos de uso principales:**
  - Dar y quitar permisos a emisores.
  - Emitir certificado.
  - Revocar certificado.
  - Verificar certificado.
- **Reglas clave:**
  - **No transferibilidad** (soulbound).
  - **Metadatos verificables** (en IPFS).
  - **Registro de revocación** accesible públicamente.

---

## 2) Diseño de Arquitectura Mínima
- **Un contrato principal:**  
  Basado en `ERC-721` + `AccessControl` + lógica soulbound.
- **Estructura de datos del certificado:**  
  `issuer`, `holder`, `degree`, `major`, `fecha`, `CID/IPFS`, `hash`, `revoked`.
- **Decisión de estándar soulbound:**  
  Propio, **EIP-5192** (minimal lock) o **ERC-5484** (consensual SBT).
- **Diagrama simple de componentes:**  
  `Contrato ↔ IPFS ↔ dApp`.

---

## 3) Setup del Proyecto (Repo y Tooling)
- **Monorepo:**  
  `contracts/`, `tests/`, `scripts/`, `frontend/`, `docs/`
- **Stack:**  
  Hardhat + Ethers + TypeScript
- **Dependencias:**  
  OpenZeppelin (ERC-721, AccessControl)
- **Tooling adicional:**
  - Prettier + Solhint + Git Hooks (lint/format antes de commit)
  - `.env` para RPC/keys (no subir secrets al repo)

---

## 4) Modelo de Permisos
- **Roles:**  
  `DEFAULT_ADMIN_ROLE` y `ISSUER_ROLE`
- **Flujos:**  
  - Otorgar y remover `ISSUER_ROLE`
  - Validar quién puede revocar certificados
- **Eventos:**  
  - `IssuerGranted(address issuer)`
  - `IssuerRevoked(address issuer)`

---

## 5) Lógica Soulbound
- **Bloquear funciones de transferencia:**
  - `transferFrom`
  - `safeTransferFrom`
  - `approve`
  - `setApprovalForAll`
- Si usás **EIP-5192:**  
  `locked(tokenId) = true`
- **Tests:**  
  Confirmar que no hay forma de transferir ni aprobar.

---

## 6) Emisión y Revocación
- `issueCertificate(holder, degree, major, cid, hash)`  
  → **Solo emisor autorizado**
- `revoke(tokenId)`  
  → **Solo la institución emisora**
- **Eventos:**
  - `Issued(tokenId, issuer, holder)`
  - `Revoked(tokenId, issuer)`

---

## 7) Metadatos y Archivos
- **IPFS:**  
  Almacenar JSON + PDF/JPG del diploma.
- **Contrato:**  
  Guardar CID y hash.
- **Estructura mínima del JSON:**

```jsonc
{
  "name": "Certificado de Título",
  "description": "Certificado emitido por la institución X",
  "attributes": [
    { "trait_type": "Degree", "value": "Ingeniería" },
    { "trait_type": "Major", "value": "Sistemas" },
    { "trait_type": "Date", "value": "2025-09-21" }
  ],
  "image": "ipfs://<CID-del-PDF-o-JPG>"
}
```
---

## 8) Seguridad Base
- **Validaciones de inputs:**  
  - `require(address != 0)` para evitar direcciones nulas.  
  - Strings requeridos no vacíos.  
- **Reentrancy:**  
  Documentar riesgo (aunque es bajo en este caso, al no haber transferencias de ETH).  
- **Pausable (opcional):**  
  Para emergencias o mantenimiento.  
- **Fuzzing tests:**  
  Pruebas de rangos razonables para detectar comportamientos inesperados.

---

## 9) Suite de Tests (Contratos)
- **Cobertura:**  
  - Permisos de Admin e Issuer.  
  - Emisión válida de certificados.  
  - No transferibilidad.  
  - Revocación de certificados.  
  - Lectura de datos y emisión de eventos.
- **Tests negativos:**
  - Emisor no autorizado intenta emitir.
  - Token inexistente.
  - Revocación de un token dos veces.
  - Intentos de transferencia o aprobación.
- **Objetivo:**  
  Cobertura de tests **> 90%**.

---

## 10) Scripts de Despliegue y Uso
- **Comandos:**  
  - `deploy:local` — para pruebas en red local.  
  - `deploy:testnet` — para pruebas en Sepolia u otra testnet.  
- **Scripts incluidos:**  
  - Agregar emisores de ejemplo.  
  - Emitir certificados de prueba.  
  - Revocar y verificar estado.

---

## 11) Despliegue en Testnet
- Elegir red (recomendado: **Sepolia**).
- Configurar variables de entorno para RPC y private keys.
- Verificar contrato en **Etherscan** o **Blockscout**.
- Guardar direcciones desplegadas en `docs/addresses.json`.

---

## 12) Frontend Mínimo (Verificación Pública)
- **Página de verificación:**  
  - Input `tokenId` o `address`.  
  - Mostrar datos **on-chain** + metadatos de IPFS + estado de revocación.
- **Panel de emisor:**  
  - Conectar wallet.  
  - Emitir y revocar (solo si tiene `ISSUER_ROLE`).
- **Stack recomendado:**  
  - wagmi/viem para conexión a la blockchain.  
  - RainbowKit para UI de wallet connect.
- **UX:**  
  Manejo de errores, loaders y feedback al usuario.

---

## 13) Flujo de Verificación para Terceros
- **Guía en `docs/`:**  
  1. Consultar contrato on-chain.  
  2. Validar hash del PDF con el registrado en blockchain.
- **Acceso directo:**  
  Ruta `/verify/:tokenId` para acceder fácilmente a la información de un certificado.

---

## 14) CI/CD del Repo
- **GitHub Actions:**  
  - Lint + tests + coverage en cada PR.  
- **Opcional:**  
  - Deploy automático del frontend en Vercel o Netlify.
- **Extras:**  
  - Badges de status y cobertura en el `README.md`.

---

## 15) Gas y Performance
- **Optimización de tipos:**  
  - `uint64` para fechas.  
  - `bytes32` para hashes.
- **Eventos:**  
  - Mantenerlos livianos (sin strings pesados).  
- **Mediciones:**  
  - Revisar costos de `mint` y `revoke`.

---

## 16) Documentación del Proyecto
- **README:**  
  - Pitch corto.  
  - Features principales.  
  - Diagrama de arquitectura.  
  - Estándares usados.  
  - Instrucciones para correr tests, deploy y demo.
- **Directorio `docs/`:**  
  - Casos de uso.  
  - Modelo de datos.  
  - Decisiones de diseño.  
  - Amenazas y mitigaciones.
- **Capturas/GIFs:**  
  Mostrar frontend y flujo de uso.

---

## 17) Demo y Muestras
- Crear 2–3 instituciones demo.
- Emitir 4–6 certificados.
- Subir PDF/JPG a IPFS.
- Publicar direcciones y `tokenId`s de prueba en el `README.md`.

---

## 18) Licencia y Cumplimiento
- Agregar **SPDX headers** en contratos.
- Licencia del repo: **MIT** o **Apache-2.0**.
- Aclarar que es un proyecto de **demo** y no un sustituto legal.

---

## 19) Roadmap y “Nice to Have”
- Soporte para **ERC-5484** (SBT consensual con aceptación del holder).
- Listado on-chain de emisores verificados.
- Firma off-chain de la institución + verificación on-chain.
- Multi-título por address (consulta de certificados por holder).
- Indexación con **The Graph** para búsquedas rápidas.
- Soporte multi-red / L2 (Base, Arbitrum, Optimism).
- Exportación de certificados verificables (QR con `tokenId` + `CID` + hash).

---

## 20) Revisión Final (Audit-Style)
- Pasar herramientas de análisis estático: **Slither**, **Surya**.
- Documentar hallazgos y remediaciones.
- Revisar controles de acceso y tests negativos.
- Mensajes de error claros y descriptivos.
- Validar UX: un verificador debe poder confirmar un certificado en **< 30s**.

---
