# Objetivo del Proyecto

El proyecto tiene como objetivo desarrollar un **sistema basado en blockchain** que permita a las instituciones educativas **emitir certificados estudiantiles únicos** —como títulos o aprobaciones de materias— y que los estudiantes puedan **almacenarlos de forma segura** en la red.  
Además, el sistema permitirá la **verificación pública y transparente** de los certificados emitidos, garantizando:
- **Autenticidad**
- **Trazabilidad**
- **Resistencia a la falsificación**

---

# Roles del Sistema

- **Admin**  
  Gestiona la lista de instituciones autorizadas para emitir certificados.  
  Otorga o revoca permisos a las cuentas que actúan como emisores.

- **Institución (Emisor)**  
  Crea y asigna certificados académicos a los estudiantes.  
  Puede revocar certificados previamente emitidos.

- **Estudiante (Holder)**  
  Recibe su certificado académico como **token soulbound** (intransferible).  
  Puede compartir su dirección pública para demostrar la validez de sus certificados.

- **Verificador**  
  Cualquier tercero (empresa, universidad, organismo) que consulta la blockchain para comprobar:
  - La **autenticidad** de un certificado.
  - A qué estudiante pertenece.
  - Si está vigente o fue revocado.

---

# Principales Casos de Uso

### 1. Gestionar emisores
- El **Admin** otorga permisos a una institución para emitir certificados.
- El **Admin** puede revocar esos permisos si la institución ya no está autorizada.

### 2. Emitir certificado
- Una **institución autorizada** emite un certificado académico **soulbound** a un estudiante.
- El certificado se registra en la blockchain con **metadatos**:
  - Título, materia, fecha, hash del documento, etc.

### 3. Revocar certificado
- La **institución emisora** puede revocar un certificado en caso de:
  - Error
  - Fraude
  - Actualización
- El estado del certificado (vigente o revocado) queda **públicamente disponible**.

### 4. Verificar certificado
- Un **verificador** consulta la blockchain para confirmar si un certificado es válido.
- Puede comprobar:
  - Quién lo emitió.
  - A qué estudiante pertenece.
  - Si fue revocado.

---

# Reglas Clave del Proyecto

1. **No transferibilidad**  
   Los certificados son tokens **soulbound**: una vez emitidos quedan permanentemente vinculados a la dirección del estudiante y **no pueden transferirse ni venderse**.

2. **Emisión restringida**  
   - Solo las **instituciones autorizadas** por el Admin pueden emitir certificados.  
   - Ningún usuario sin rol de emisor puede crearlos.

3. **Revocación controlada**  
   - Solo la **institución emisora** puede revocar un certificado.  
   - El estado de revocación debe ser **visible públicamente**.

4. **Metadatos verificables**  
   - Cada certificado incluye: grado, materia, fecha, institución emisora, etc.  
   - El archivo asociado (ejemplo: PDF o imagen del diploma) se almacena en **IPFS** y se vincula mediante un **hash** en la blockchain para garantizar integridad.

5. **Autenticidad y trazabilidad**  
   - Todos los certificados son **únicos** e **identificables** en la blockchain.  
   - Cualquier tercero puede comprobar **quién emitió** el certificado y **a quién pertenece**.

6. **Gestión de permisos**  
   - El **Admin** controla qué instituciones pueden emitir certificados.  
   - Los estudiantes **no pueden modificarlos ni eliminarlos**.

7. **Accesibilidad pública**  
   - La verificación de certificados debe ser posible **sin permisos especiales**, solo con la **public key** del estudiante.

---

> **Nota:** Este diseño prioriza la seguridad, auditabilidad y descentralización, asegurando que los certificados sean confiables y fáciles de verificar por cualquier actor en el ecosistema.
