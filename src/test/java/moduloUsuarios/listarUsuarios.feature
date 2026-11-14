@testListarUsuarios
Feature: Pruebas del endpoint Listar Usuarios

  Background:
    * url 'https://serverest.dev'

  @listarTodosUsuarios @regresion @happypath
  Scenario: Listar todos los usuarios registrados
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#array'
    And match each response.usuarios contains
      """
      {
        "nome": "#string",
        "email": "#string",
        "password": "#string",
        "administrador": "#string",
        "_id": "#string"
      }
      """

  @listarPorFiltro @regresion @happypath
  Scenario: Filtrar usuarios usando un parámetro válido (parametro administrador)
    Given path '/usuarios'
    And param administrador = 'true'
    When method GET
    Then status 200
    And match response.usuarios == '#array'
    And match each response.usuarios contains { administrador: 'true' }

  @listarMultiplesFiltros @regresion @happypath
  Scenario Outline: Filtrar usuarios usando múltiples parámetros (<caso>)
    # 1. Generamos un correo único y lo inyectamos en el payload del JSON
    * def correoUnico = 'filtro_' + java.lang.System.currentTimeMillis() + '@ejemplo.com'
    * set payload.email = correoUnico

    # 2. Registro de nuevo usuario
    Given path '/usuarios'
    And request payload
    When method POST
    Then status 201

    # 3. Consulta filtrando dinámicamente con los datos del JSON
    Given path '/usuarios'
    And params { nome: '#(payload.nome)', email: '#(correoUnico)', administrador: '#(payload.administrador)' }
    When method GET
    Then status 200
    And match response.quantidade == 1
    And match response.usuarios[0].email == correoUnico
    And match response.usuarios[0].nome == payload.nome
    And match response.usuarios[0].administrador == payload.administrador
    Examples:
      | read('classpath:datos/ddtListarUsuarios/usuarios_filtro.json') |


  @listarUsuarioInexistente @regresion @happypath
  Scenario: Búsqueda válida pero usuario no esta en la base de datos
    Given path '/usuarios'
    And param email = 'usuario_inexistente_999999@correo.com'
    When method GET
    Then status 200
    And match response ==
      """
      {
        "quantidade": 0,
        "usuarios": []
      }
      """

  @listarParametroNoPermitido @regresion @unhappypath
  Scenario: Error al enviar un parámetro no permitido para consultar
    Given path '/usuarios'
    And param edad = '30'
    When method GET
    Then status 400
    And match response ==
      """
      {
        "edad": "edad não é permitido"
      }
      """

  @listarParametroInvalido @regresion @unhappypath
  Scenario: Error al enviar un parámetro con formato o valor inválido
    Given path '/usuarios'
    And params { administrador: 'talvez', email: 'correo-sin-arroba' }
    When method GET
    Then status 400
    And match response ==
      """
      {
        "administrador": "administrador deve ser 'true' ou 'false'",
        "email": "email deve ser um email válido"
      }
      """

