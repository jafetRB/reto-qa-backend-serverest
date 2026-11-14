# Automatización de Pruebas API - ServeRest (Karate DSL)

Este proyecto contiene la suite de pruebas automatizadas para validar los endpoints CRUD de usuarios de la API pública **ServeRest** (`https://serverest.dev`), desarrollado con **Java**, **Maven Surefire (JUnit 5)** y **Karate DSL**.

---

## 📋 Requisitos Previos

Antes de ejecutar las pruebas, asegúrate de contar con lo siguiente:

* **Java JDK:** Versión 17 o superior.
* **Apache Maven:** Versión 3.8 o superior (o el gestor Maven integrado en IntelliJ IDEA).
* **Conexión a Internet:** Necesaria para descargar dependencias de Maven y comunicarse con `https://serverest.dev`.

---

## 📁 Estructura del Proyecto

```text
pruebas-api-karate/
├── src/
│   └── test/
│       ├── java/
│       │   ├── TestRunner.java                     # Runner principal con JUnit 5 y generador de reportes
│       │   └── moduloUsuarios/
│       │       ├── listarUsuarios.feature          # Escenarios GET /usuarios (Listar y filtrar)
│       │       ├── registrarUsuario.feature        # Escenarios POST /usuarios (Crear usuario)
│       │       ├── buscarUsuario.feature           # Escenarios GET /usuarios/{_id}
│       │       ├── actualizarUsuario.feature       # Escenarios PUT /usuarios/{_id}
│       │       └── eliminarUsuario.feature         # Escenarios DELETE /usuarios/{_id}
│       └── resources/
│           └── datos/                              # Datos de prueba JSON externos (Data-Driven Testing)
│               ├── ddtListarUsuarios/              # Datos para GET /usuarios
│               ├── ddtRegistrarUsuario/            # Datos para POST /usuarios
│               ├── ddtBuscarUsuario/               # Datos para GET /usuarios/{_id}
│               ├── ddtActualizarUsuario/           # Datos para PUT /usuarios/{_id}
│               └── ddtEliminarUsuario/             # Datos para DELETE /usuarios/{_id}
├── target/                                         # Carpeta autogenerada con compilados y reportes HTML
├── pom.xml                                         # Configuración de dependencias (karate-junit5) y Surefire
└── README.md                                       # Documentación del proyecto
```

---

## 🚀 Ejecución de las Pruebas

Puedes ejecutar las pruebas desde la **terminal**, mediante **Maven en IntelliJ IDEA**, o directamente desde la clase **`TestRunner.java`**.

### 1. Ejecución Estándar (Todos los escenarios o tag definido en código)
Ejecuta todos los escenarios dentro de `moduloUsuarios` (o el tag configurado en `.tags(...)` dentro de `TestRunner.java`):
```bash
mvn clean test
```

### 2. Ejecución Filtrando por Etiquetas (Tags) desde Consola
Utiliza el parámetro `-Dkarate.options` para sobrescribir cualquier filtro y ejecutar un grupo específico de pruebas:

* **Ejecutar un tag específico (ejemplo `@eliminarIdInexistente`):**
  ```bash
  mvn clean test -Dkarate.options="--tags @eliminarIdInexistente"
  ```

* **Ejecutar toda la suite (Happy y Unhappy Paths):**
  ```bash
  mvn clean test -Dkarate.options="--tags @regresion"
  ```

* **Ejecutar solo pruebas Happy Path (casos positivos):**
  ```bash
  mvn clean test -Dkarate.options="--tags @happypath"
  ```

* **Ejecutar solo pruebas Unhappy Path (validaciones y errores):**
  ```bash
  mvn clean test -Dkarate.options="--tags @unhappypath"
  ```

* **Ejecutar solo pruebas de un Feature relacionadas al endpoint ( ejemplo `@testActualizarUsuario`):**
  ```bash
  mvn clean test -Dkarate.options="--tags @testActualizarUsuario"
  ```

### 3. Ejecución desde IntelliJ IDEA
* **Ejecución directa:** Abre `src/test/java/TestRunner.java` y haz clic en el botón verde **Run** junto al método `testParallel()`.
* **Con configuración Maven:** Ve a **Run** > **Edit Configurations...**, selecciona tu configuración de **Maven** y escribe en el campo **Command line** el comando deseado sin la palabra `mvn`:
  ```text
  clean test -Dkarate.options="--tags @regresion"
  ```

---

## 📊 Visualización de Reportes

Al finalizar cada ejecución, el proyecto genera automáticamente tres tipos de reportes dentro de la carpeta `target/`:

1. **Reporte Avanzado de Cucumber (Recomendado):**
   * **Ruta:** `target/cucumber-html-reports/overview-features.html`
   * **Contenido:** Gráficos estadísticos, porcentaje de éxito, filtrado por tags, tiempos de respuesta y detalle completo de peticiones/respuestas.

2. **Reporte Nativo de Karate:**
   * **Ruta:** `target/karate-reports/karate-summary.html`
   * **Contenido:** Resumen paso a paso de cada escenario ejecutado y trazas HTTP.

3. **Reportes XML de Surefire (Para CI/CD):**
   * **Ruta:** `target/surefire-reports/`
   * **Contenido:** Archivos XML estándar compatibles con Jenkins, GitHub Actions, GitLab CI y Azure DevOps.

> **Tip:** Para abrir cualquiera de los reportes HTML en IntelliJ IDEA, haz clic derecho sobre el archivo y selecciona **Open In** > **Browser** y seleccionar el Navegador de su preferencia.
