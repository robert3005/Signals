class radialMenu
  event: ""

  description: ""
  text: ""

  expanded: false
  expandedChildren: false
  visible: false

  constructor: ( @engine, @canvas, @x, @y, @text, @desc ) ->
    if not @mousedownLister
      @canvas.addEventListener this
      @mousedownListener = true

    ###
    This is a title displayed next to the menu item. It is hidden by
    default and shown only when menu item is in visibile state
    ###
    @$title = $ "<div/>"
    @$title.text @text
    @$title.appendTo 'body'
    @$title.css 'display', 'none'
    @$title.click =>
      @click()

    ###
    Get the context and stage we will be drawing to. Only for the root it will be the actuall context, for every other element it will get
    overwritten by root's context and stage.
    ###
    @context2d = @canvas.getContext '2d'
    @stage = new Stage @canvas

    #Container where we store all our children
    @container = new Container()

    #My parent
    @parent = null

    #Current coordinates
    @x ?= 0
    @y ?= 0

    ###
    Distances from the origin in different states.
    ###
    @length = 0

    @length_base = 100
    @expand_length = @length_base
    @compact_length = @length_base * 0.5

    #Constants
    @expandTime = 500
    @compactTime = 500
    @hideTime = 200
    @showTime = 200

    @priority = 100

    #Alphas
    @fadedInOpacity = 1
    @fadedOutOpacity = 0.2
    @opacity = 1

    #Flags
    @visible = false
    @expanded = false
    @expanding = false #visible -> expanded
    @collapsing = false #expanded -> collapsed
    @showing = false #hidden -> visible
    @hiding = false #visible -> hidden
    @drawn = false

    #Radius of the button
    @radius = 10

    #Angles
    @alpha = Math.PI / 6
    @beta = -Math.PI

    #Children elements - class radialMenu
    @children = []

    #Boundaries of the object, used for hit detection
    @boundaries =
      x: @x - @radius
      y: @y - @radius
      width: @radius * 2
      height: @radius * 2

  addChild: ( menu ) ->
    menu.priority = @priority - 1
    menu.stage = @stage
    menu.parent = @
    menu.beta = menu.beta - @children.length * @alpha
    [x,y] = menu.computeP()
    menu.x = x
    menu.y = y

    @children.push menu


  computeP: ( length ) ->
    if not length?
      length = @length

    x = length * Math.sin( @beta )
    y = length * Math.cos( @beta )

    [x,y]

  drawIt: () =>
    @draw()

    c.drawIt() for c in @children

  draw: () =>
    if @drawn
      return false

    @drawn = true
    @button = new Shape()

    @button.graphics
      .beginStroke( "red" )
      .beginFill( "red" )
      .drawCircle( @x, @y, @radius )

    P = @button.localToGlobal @x, @y

    @$title.css
      'position': 'absolute'
      'left': P.x
      'top': P.y
      'opacity' : 1
      'cursor' : 'pointer'

    if not @parent?
      @stage.addChild @button
      @stage.addChild @container
    else
      @parent.container.addChild @button
      @parent.container.addChild @container

    @button.visible = false

    #update boundaries
    @boundaries =
      x: P.x - @radius
      y: P.y - @radius
      width: @radius * 2
      height: @radius * 2

    c.draw() for c in @children

    @button.cache @x-@radius, @x-@radius, @radius * 2, @radius * 2

    ###
    Register us as a listener for the Mouse and the Ticker
    ###
    @mId = Mouse.register @, @click, ['click'], @priority
    Ticker.addListener @, false

  restoreFlags: () =>
    @expanded = false
    @expandedChildren = false
    @visible = false

  show: () =>
    if not @drawn
      @draw()

    @showing = true
    @hiding = false

    [x,y] = @computeP @length_base

    if @parent? and @x != x and @y != y
      @steps = @showTime/Ticker.getInterval()
      @stepX = (x-@x)/@steps
      @stepY = (y-@y)/@steps
      @stepOpacity = (1-@opacity)/@steps
    else
      @steps = 0
      @stepX = 0
      @stepY = 0
      @stepOpacity = 0

    @$title.show()
    @button.visible = true

  hide: () =>
    @showing = false
    @hiding = true

    x = 0
    y = 0

    if @parent?  and @x != x and @y != y
      @steps = @showTime/Ticker.getInterval()
      @stepX = @x/@steps
      @stepY = @y/@steps
      @stepOpacity = (-@opacity)/@steps
    else
      @steps = 0
      @stepX = 0
      @stepY = 0
      @stepOpacity = 0

    @hideChildren()

  expand: ( expandChildren ) =>
    console.log "expand"

    if not @visible
      @show()

    @expanding = true
    @collapsing = false

    [x,y] = @computeP @expand_length

    if @parent?  and @x != x and @y != y
      @steps = @showTime/Ticker.getInterval()
      @stepX = (x-@x)/@steps
      @stepY = (y-@y)/@steps
      @stepOpacity = (@fadedInOpacity-@opacity)/@steps
    else
      @steps = 0
      @stepX = 0
      @stepY = 0
      @stepOpacity = 0

    if expandChildren
      c.show() for c in @children
      @expanded = true

  collapseChildren: ( child ) =>
    (
      if c != child
        c.collapse()
    ) for c in @children

  hideChildren: () =>
    @expanded = false
    c.hide() for c in @children

  collapse: () =>
    @collapsing = true
    @expanding = false

    [x,y] = @computeP @compact_length

    if @parent?  and @x != x and @y != y
      @steps = @showTime/Ticker.getInterval()
      @stepX = (@x-x)/@steps
      @stepY = (@y-y)/@steps
      @stepOpacity = (@fadedOutOpacity-@opacity)/@steps
    else
      @steps = 0
      @stepX = 0
      @stepY = 0
      @stepOpacity = 0

    @hideChildren()

  showAnimate: () =>
    if @steps <= 0
      @showing = false
      @visible = true
      @$title.show()
    else
      @steps--
      @x += @stepX
      @y += @stepY
      @opacity += @stepOpacity

  hideAnimate: () =>
    if @steps <= 0
      @hiding = false
      @visible = false
      @$title.hide()
    else
      @steps--
      @x -= @stepX
      @y -= @stepY
      @opacity += @stepOpacity


  collapseAnimate: () =>
    if @steps <= 0
      @collapsing = false
      @expanded = false
    else
      @x -= @stepX
      @y -= @stepY
      @opacity += @stepOpacity
      @steps--

  expandAnimate: () =>
    if @steps <= 0
      @expanding = false
    else
      @x += @stepX
      @y += @stepY
      @opacity += @stepOpacity
      @steps--

  click: () =>
    if not @expanded
      @expand true #show my children

      if @parent?
        @parent.collapseChildren @
    else
      @hideChildren()

  in: ( x, y ) =>
    @button.hitTest x, y

  tick: ( time ) =>
    if not @drawn
      return false

    #perform animations
    if @showing
      @showAnimate()

    if @hiding
      @hideAnimate()

    if @expanding
      @expandAnimate()

    if @collapsing
      @collapseAnimate()

    ###
    Apply new coordinates computated by animating functions
    ###
    @button.x = @x
    @button.y = @y

    @button.alpha = @opacity
    @$title.css 'opacity', @opacity

    if @parent?
      @container.x = @x
      @container.y = @y
    else
      @container.x = 2*@x
      @container.y = 2*@y

    if not @parent
      global = @button.localToGlobal @button.x, @button.y
    else
      global = @parent.container.localToGlobal @button.x, @button.y

    rotation = - (@beta) * 180/Math.PI + 90

    if @parent?
      xTrans = 15 * Math.sin @beta
      yTrans = -10 + 15 *Math.cos @beta

      @$title.css
        top: global.y + yTrans
        left: global.x + xTrans
        '-webkit-transform-origin': 'left center'
        '-webkit-transform': 'rotate('+ (rotation) + 'deg)'
    else
      @$title.css
        top: global.y - 10
        left: global.x + 15

    #update boundaries
    @boundaries =
      x: global.x - @radius
      y: global.y - @radius
      width: @radius * 2
      height: @radius * 2

    ###
    We do not want to update the stage too many times so we call this
    only from the root element of the menu
    ###
    if not @parent?
      @stage.update()

$ ->
  canvas = document.getElementById "radial"
  if canvas?
    window.Mouse = new MouseClass canvas

    window.r = r = new radialMenu null, canvas, 150, 150, "piesek"

    r2 = new radialMenu null, canvas, 0, 0, "kotek"
    r3 = new radialMenu null, canvas, 0, 0, "malpka"
    r4 = new radialMenu null, canvas, 0, 0, "ptaszek"
    r0 = new radialMenu null, canvas, 0, 0, "dziubek"

    r5 = new radialMenu null, canvas, 0, 0, "gawron"
    r6 = new radialMenu null, canvas, 0, 0, "slon"
    r7 = new radialMenu null, canvas, 0, 0, "dzwon"
    r8 = new radialMenu null, canvas, 0, 0, "dzwon1"
    r9 = new radialMenu null, canvas, 0, 0, "dzwon2"

    r.addChild r2
    r.addChild r3
    r.addChild r4
    r.addChild r0

    r4.addChild r5
    r4.addChild r6
    r4.addChild r7
    r4.addChild r8
    r4.addChild r9

    r.drawIt()
    r.show()

