@testActualizarUsuario
Feature: Pruebas del enpoint Actualizar Usuarios

Feature: Editar usuarios en ServeRest (PUT /usuarios/{_id})

  Background:
    * url 'https://serverest.dev'

  @actualizarUsuario @regresion @happypath
  Scenario Outline: Editar exitosamente un usuario existente (<caso>)
    # 1. Generamos correos únicos e inyectamos ambos en sus respectivos payloads
    * def correoInicial = 'editar_orig_' + java.lang.System.currentTimeMillis() + '@correo.com'
    * def correoEditado = 'editar_nuevo_' + java.lang.System.currentTimeMillis() + '@correo.com'
    * set usuarioInicial.email = correoInicial
    * set usuarioEditado.email = correoEditado

    # 2. Creación de nuevo usuario
    Given path '/usuarios'
    And request usuarioInicial
    When method POST
    Then status 201
    * def idUsuario = response._id

    # 3. Actualización de todos sus datos
    Given path '/usuarios', idUsuario
    And request usuarioEditado
    When method PUT
    Then status 200
    And match response ==
      """
      {
        "message": "Registro alterado com sucesso"
      }
      """

    # 4. Verificación de datos modificados contra el JSON editado
    Given path '/usuarios', idUsuario
    When method GET
    Then status 200
    And match response ==
      """
      {
        "nome": "#(usuarioEditado.nome)",
        "email": "#(correoEditado)",
        "password": "#(usuarioEditado.password)",
        "administrador": "#(usuarioEditado.administrador)",
        "_id": "#(idUsuario)"
      }
      """
    Examples:
      | read('classpath:datos/ddtActualizarUsuario/usuarios_editar.json') |

  @registroExitosoPUT @regresion @happypath
  Scenario: Crear usuario usando meotodo PUT cuando el ID de 16 caracteres no existe
    * def idInexistente = 'ZZZ999' + (java.lang.System.currentTimeMillis() + '').substring(3)
    * def correoNuevo = 'put_creacion_' + java.lang.System.currentTimeMillis() + '@correo.com'

    Given path '/usuarios', idInexistente
    And request
      """
      {
        "nome": "Usuario Creado Por PUT",
        "email": "#(correoNuevo)",
        "password": "Password123",
        "administrador": "true"
      }
      """
    When method PUT
    Then status 201
    And match response ==
      """
      {
        "message": "Cadastro realizado com sucesso",
        "_id": "#string"
      }
      """

  @actualizarIdInvalido @regresion @unhappypath
    Scenario Outline: Error al intentar editar con un ID de formato o longitud inválida (<caso>)
    * def correoUnico = 'clarita' + java.lang.System.currentTimeMillis() + '@correo.com'
    * set payload.email = correoUnico

    Given path '/usuarios', idInvalido
    And request payload
    When method PUT
    Then status 201
    And match response ==
      """
      {
        "message": "Cadastro realizado com sucesso",
        "_id": "#string"
      }
      """
    Examples:
      | read('classpath:datos/ddtActualizarUsuario/ids_invalidos.json') |

  @actualizarCorreoExistente @regresion @unhappypath
  Scenario Outline: Error al editar usando un correo que ya pertenece a otro usuario (<caso>)
    # 1. Generamos correos únicos e inyectamos el correo del Usuario A en el payload de edición del Usuario B
    * def timestamp = java.lang.System.currentTimeMillis()
    * def correoUsuarioA = 'usuarioA_' + timestamp + '@correo.com'
    * def correoUsuarioB = 'usuarioB_' + timestamp + '@correo.com'
    * set usuarioA.email = correoUsuarioA
    * set usuarioB.email = correoUsuarioB
    * set usuarioBEditado.email = correoUsuarioA

    # 2. Creación del Usuario A
    Given path '/usuarios'
    And request usuarioA
    When method POST
    Then status 201

    # 3. Creación del Usuario B
    Given path '/usuarios'
    And request usuarioB
    When method POST
    Then status 201
    * def idUsuarioB = response._id

    # 4. Actualizar el Usuario B asignando el correo del Usuario A
    Given path '/usuarios', idUsuarioB
    And request usuarioBEditado
    When method PUT
    Then status 400
    And match response ==
      """
      {
        "message": "Este email já está sendo usado"
      }
      """
    Examples:
      | read('classpath:datos/ddtActualizarUsuario/usuarios_editar_duplicado.json') |


  @actualizarCamposInvalidos @regresion @unhappypath
  Scenario Outline: Error al actualizar campos con valores inválidos (<caso>)
    Given path '/usuarios', '0uxuPY0cbmQhpEz9'
    And request payload
    When method PUT
    Then status 400
    And match response == errorEsperado
    Examples:
      | read('classpath:datos/ddtActualizarUsuario/usuarios_editar_invalidos.json') |


  @actualizarAtributoNoPermitido @regresion @unhappypath
  Scenario: Error al enviar un atributo extra no permitido en el cuerpo JSON
    Given path '/usuarios', '0uxuPY0cbmQhpEz9'
    And request
      """
      {
        "nome": "Pepita Yaipen",
        "email": "pepita.extra@correo.com",
        "password": "Password123",
        "administrador": "true",
        "telefono": "999888777"
      }
      """
    When method PUT
    Then status 400
    And match response ==
      """
      {
        "telefono": "telefono não é permitido"
      }
      """


