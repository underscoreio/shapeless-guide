$ = require 'jquery'

init = (toggle, toc) ->
  toggle = $(toggle)
  toc    = $(toc)

  toggle.on 'click', (evt) ->
    toc.slideDown()
    toggle.remove()
    return

  return

module.exports = {
  init
}