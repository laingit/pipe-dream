function init () {
  var node = document.getElementById('elm-app')
  var app = Elm.Main.embed(node)
}

module.exports = { init }
