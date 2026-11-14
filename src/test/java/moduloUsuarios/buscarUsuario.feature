@testBuscarUsuario
Feature: Pruebas del enpoint Buscar Usuario

  Background:
    * url 'https://serverest.dev'

  @busquedaNuevoUsuario @regresion @happypath
  Scenario: Buscar un usuario recién creado por su ID
    # 1. Registro de nuevo usuario para asegurar que el _id es valido
    * def correoUnico = 'buscar_id_' + java.lang.System.currentTimeMillis() + '@ejemplo.com'
    Given path '/usuarios'
    And request
      """
      {
        "nome": "Pepito Castro",
        "email": "#(correoUnico)",
        "password": "Password123",
        "administrador": "true"
      }
      """
    When method POST
    Then status 201
    * def idUsuarioCreado = response._id

    # 2. Consulta con el _id capturado en el paso anterior
    Given path '/usuarios', idUsuarioCreado
    When method GET
    Then status 200
    And match response ==
      """
      {
        "nome": "Pepito Castro",
        "email": "#(correoUnico)",
        "password": "Password123",
        "administrador": "true",
        "_id": "#(idUsuarioCreado)"
      }
      """

  @busquedaPrimero @regresion @happypath
  Scenario: Buscar el primer usuario del listado general por su ID
    # 1. Listado de usuarios
    Given path '/usuarios'
    When method GET
    Then status 200
    * def primerId = response.usuarios[0]._id

    # 2. Consulta por el _id específico
    Given path '/usuarios', primerId
    When method GET
    Then status 200
    And match response ==
      """
      {
        "nome": "#string",
        "email": "#string",
        "password": "#string",
        "administrador": "#string",
        "_id": "#(primerId)"
      }
      """

  @busquedaIdInexistente @regresion @unhappypath
  Scenario: Error al buscar un ID con longitud válida pero inexistente
    Given path '/usuarios', '0uxuPY0cbmQhpEz9'
    When method GET
    Then status 400
    And match response ==
      """
      {
        "message": "Usuário não encontrado"
      }
      """

  @busquedaIdInvalido @regresion @unhappypath
  Scenario Outline: Error al enviar un ID con longitud o formato inválido (<caso>)
    Given path '/usuarios', idInvalido
    When method GET
    Then status 400
    And match response ==
      """
      {
        "id": "id deve ter exatamente 16 caracteres alfanuméricos"
      }
      """
    Examples:
      | read('classpath:datos/ddtBuscarUsuario/ids_invalidos.json') |

