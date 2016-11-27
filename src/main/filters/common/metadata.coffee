_      = require 'underscore'
pandoc = require 'pandoc-filter'

getString = (meta, key) ->
  stringify = (node) ->
    if _.isArray(node)
      _.map(node, stringify).join("")
    else if node?.t?
      switch node.t
        when "Space" then " "
        else stringify(node.c)
    else if node?
      "#{node}"
    else undefined

  ref = (node, key) ->
    if key.length == 0
      stringify(node)
    else
      switch node?.t
        when 'MetaMap'     then ref(node.c[key[0]], key.slice(1))
        when 'MetaList'    then ref(node.c[key[0]], key.slice(1))
        when 'MetaBool'    then undefined
        when 'MetaString'  then undefined
        when 'MetaInlines' then undefined
        when 'MetaBlocks'  then undefined
        else undefined

  if key == [] then stringify(meta) else ref(meta[key[0]], key.slice(1))

getInt = (meta, key) ->
  str = getString(meta, key)
  if str? then parseInt(str, 10) else str

module.exports = {
  getString
  getInt
}
