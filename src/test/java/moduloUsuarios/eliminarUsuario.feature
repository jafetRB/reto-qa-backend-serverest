@testEliminarUsuario
Feature: Pruebas del enpoint Eliminar Usuario

  Background:
    * url 'https://serverest.dev'

  @eliminarUsuarioSinCarrito @regresion @happypath
  Scenario Outline: Eliminar exitosamente un usuario existente sin carrito (<perfil>)
    # 1. Generamos un correo único y lo asignamos al payload del JSON
    * def correoUnico = 'usuarioParaEliminar_' + java.lang.System.currentTimeMillis() + '@correo.com'
    * set payload.email = correoUnico

    # 2. Creación de nuevo usuario para no borrar datos existentes
    Given path '/usuarios'
    And request payload
    When method POST
    Then status 201
    * def idUsuario = response._id

    # 3. Eliminar el usuario por su _id
    Given path '/usuarios', idUsuario
    When method DELETE
    Then status 200
    And match response ==
      """
      {
        "message": "Registro excluído com sucesso"
      }
      """

    # 4. Verificar que el usuario ya no está en la lista
    Given path '/usuarios', idUsuario
    When method GET
    Then status 400
    And match response ==
      """
      {
        "message": "Usuário não encontrado"
      }
      """
    Examples:
      | read('classpath:datos/ddtEliminarUsuario/usuarios_eliminar.json') |

  @eliminarIdInvalido @regresion @happypath
  Scenario Outline: El sistema no permite eliminar ID con longitud o formato inválido (<caso>)
    Given path '/usuarios', idInvalido
    When method DELETE
    Then status 200
    And match response ==
      """
      {
        "message": "Nenhum registro excluído"
      }
      """
    Examples:
      | read('classpath:datos/ddtEliminarUsuario/ids_invalidos.json') |


  @eliminarIdInexistente @regresion @happypath
  Scenario: El sistema no permite eliminar un ID válido de 16 caracteres que no existe
    Given path '/usuarios', '0uxuPY0cbmQhpEz9'
    When method DELETE
    Then status 200
    And match response ==
      """
      {
        "message": "Nenhum registro excluído"
      }
      """

  @eliminarUsuarioConCarrito @regresion @happypath
  Scenario: Error al intentar eliminar un usuario que tiene un carrito asociado
    # Listado de los los carritos activos y escojemos uno existente
    Given path '/carrinhos'
    When method GET
    Then status 200
    * def idUsuarioConCarrito = response.carrinhos[0].idUsuario

    # Eliminar usuario por su id guardado en el paso anterior
    Given path '/usuarios', idUsuarioConCarrito
    When method DELETE
    Then status 400
    And match response ==
      """
      {
        "message": "Não é permitido excluir usuário com carrinho cadastrado",
        "idCarrinho": "#string"
      }
      """