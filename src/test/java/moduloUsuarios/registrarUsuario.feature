@testRegistrarUsuario
Feature: Pruebas del enpoint Registro de Usuarios

  Background:
    * url 'https://serverest.dev'

  @registroExitoso @regresion @happypath
  Scenario Outline: Registrar un nuevo usuario con <rol> exitosamente
    * def correoUnico = 'usuarioprueba_' + java.lang.System.currentTimeMillis() + '@correo.com'
    * set payload.email = correoUnico
    Given path '/usuarios'
    And request payload
    When method POST
    Then status 201
    And match response ==
      """
      {
        "message": "Cadastro realizado com sucesso",
        "_id": "#string"
      }
      """
    Examples:
      | read('classpath:datos/ddtRegistrarUsuario/usuarios_validos.json') |

  @registroCorreoDuplicado @regresion @unhappypath
  Scenario Outline: Error al registrar un usuario con correo duplicado
   # 1. Generamos un correo único y lo inyectamos en ambos payloads
    * def correoUnico = 'dup_' + java.lang.System.currentTimeMillis() + '@correo.com'
    * set usuarioOriginal.email = correoUnico
    * set usuarioDuplicado.email = correoUnico

    # 2. Registro de un nuevo usuario exitoso
    Given path '/usuarios'
    And request usuarioOriginal
    When method POST
    Then status 201

    # 3. Intento de registro con el mismo correo
    Given path '/usuarios'
    And request usuarioDuplicado
    When method POST
    Then status 400
    And match response ==
      """
      {
        "message": "Este email já está sendo usado"
      }
      """
    Examples:
      | read('classpath:datos/ddtRegistrarUsuario/usuarios_duplicados.json') |

  @registroCamposInvalidos @regresion @unhappypath
  Scenario Outline: Error al enviar campos invalidos - <caso>
    Given request payload
    When method POST
    Then status 400
    And match response == errorEsperado
    Examples:
      | read('classpath:datos/ddtRegistrarUsuario/usuarios_invalidos.json') |
