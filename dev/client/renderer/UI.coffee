class UI extends Drawer
  constructor: ( @stage, @minRow, @maxRow, @engine ) ->
    super @stage, @minRow, @maxRow

    _.extend @, Backbone.Events

    @on "fieldClick", @handleClickOnField

    @curMenu = null

    @engine =
      getMenu:() ->
        [
          'pies:kot:leszek',
          'pies:malpa:swinka',
        ]
      getField: () ->
        {}

    window.Types.Events =
        pies:
          title: 'seip'
          kot:
            title: 'tok'
            leszek:
              title: 'keszel'
              desc: 'fucking mock object'
          malpa:
            title: 'aplam'
            swinka:
              title: 'akniws'
              positive: 'Buy'
              desc: 'very interesting creature'

  initializeMenus: () ->

    null

  createMenu: (i, j) ->
    p = @getPoint i, j

    menuStructure = @engine.getMenu i, j

    obj = @engine.getField i, j
    menu = new S.radialMenu null, @stage.canvas, p.x, p.y, "", "", true, obj

    eventsStructure = window.Types.Events
    submenuNames = @getPrefixes menuStructure

    ( subMenu = @buildMenu submenuName,
        eventsStructure,
        @getWithoutPrefix( submenuName, menuStructure ),
        submenuName

      menu.addChild subMenu
    ) for submenuName in submenuNames

    menu

  #name of the event element, eventsStructure - Types.Events sub object
  #eventsStructure [a:b:c] ...
  buildMenu: ( name, eventsStructure, menuStructure, fullname ) =>

    title = eventsStructure[name].title
    desc = eventsStructure[name].desc

    title ?= ""
    desc ?= ""

    if desc.length > 0
      m = new S.radialMenu null, @stage.canvas, 0, 0, title, desc
      m.setEvent fullname

      m
    else
      m = new S.radialMenu null, @stage.canvas, 0, 0, title, desc

      eventsStructure = eventsStructure[name]
      submenuNames = @getPrefixes menuStructure

      (
        subMenu = @buildMenu submenuName,
          eventsStructure,
          @getWithoutPrefix( submenuName, menuStructure ),
          fullname + ':' + submenuName

        m.addChild subMenu
      ) for submenuName in submenuNames

      m

  #Returns uniq prefixes from a list of strings
  getPrefixes: ( list ) ->
    prefixes = _.chain( list )
                .map(
                  ( el ) ->
                    el.split( ':' )[0]
                ).uniq()
                .filter(
                  ( el ) ->
                    el.length > 0
                ).value()

  #Gets elements from the list with the prefix, and returns thme without it
  getWithoutPrefix: ( prefix, list ) ->
    listWithout = _.chain( list )
                  .filter(
                    ( el ) ->
                      el.split( ':' )[0] is prefix
                  ).map(
                    ( el ) ->
                      els = ( el.split( ':' )[1..] ).join ':'
                  ).filter(
                    ( el ) ->
                      el.length > 0
                  ).value()

  handleClickOnField: ( i, j ) =>
    (menu?.hide() for menu in menuI) for menuI in @menus

    @curMenu = createMenu i, j
    @curMenu.click()


  render: (i,j) ->
    menu = createMenu i, j
    menu.drawIt()
    menu.show()

    console.log "Rendering finished"

window.S.UIClass = UI

$ ->
  canvas = document.getElementById "UI"
  if canvas?
    stage = new Stage canvas
    stage.autoclear = false
    window.UI = UI = new S.UIClass stage, 8, 15
    UI.initializeMenus()
    window.M = m = UI.createMenu 6,6
    m.drawIt()
    m.show()

