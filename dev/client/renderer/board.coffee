###
margin = 20
size = 40
count = 12
height = Math.ceil 2*margin+(3*count+1)/2*size
width = 2*margin+Math.ceil(Math.sqrt(3)*size/2)*25

hitOptions =
    segments: true
    stroke: true
    fill: true
    tolerance: 2

view.viewSize = [width,height]

onMouseMove = (event) ->
    hitResult = project.hitTest event.point, hitOptions
    project.activeLayer.selected = false
    if hitResult and hitResult.item
        hitResult.item.selected = true

drawHex = (x, y, size) ->
    hex = new Path.RegularPolygon new Point(x, y), 6, size
    hex.style =
        fillColor: new RgbColor 0, 0, 0, 0
        strokeColor: 'yellow'
        strokeWidth: 3
        selected: false
    #glow hex, strokeColor: 'yellow', strokeWidth: 10

glow = (path, glow) ->
    glow = glow || {}
    s =
        strokeWidth: (glow.strokeWidth || 10) + path.strokeWidth
        fillColor: glow.fillColor || new RgbColor 0, 0, 0, 0
        opacity: glow.opacity || .5
        translatePoint: glow.translatePoint || new Point 0, 0
        strokeColor: glow.strokeColor || "#000"

    c = s.strokeWidth / 2
    out = []
    for i in [1..c+1]
        newPath = path.clone()
        newPath.style =
            strokeColor: s.strokeColor
            fillColor: s.fillColor
            strokeJoin: "round"
            strokeCap: "round"
            strokeWidth: +(s.strokeWidth / c * i).toFixed(3)
        newPath.strokeColor.alpha = +(s.opacity / c).toFixed(3)
        newPath.moveBelow path
        out.push newPath
    out

horIncrement = Math.ceil Math.sqrt(3)*size
verIncrement = Math.ceil 3*size/2
offset = false

for y in [margin + size..height-margin-size] by verIncrement
    for x in [(margin + horIncrement/2 + (if offset then horIncrement/2 else 0))..width - margin - (if not offset then horIncrement/2 else 0)] by horIncrement
        drawHex x, y, size
    offset = not offset

path = new Path()
start = new Point margin + size, size + margin
end = new Point margin + size + horIncrement, margin+size+2*verIncrement
path.add start
path.lineTo end
path.strokeColor = '#0000ff'
path.strokeWidth = 2
size = new Size 10, 8
point = path.getPointAt 0
rectangle = new Rectangle point, size
oval = new Path.Oval rectangle
oval.fillColor = '#0000ff'
oval.position += new Point(-5, -4)

direction = end - start
onFrame = (event) ->
    if oval.position.x > end.x and oval.position.y > end.y or oval.position.x < start.x and oval.position.y < start.y
        direction = -direction
    oval.position += direction/50

###

###
CIRCLE_RADIUS = 15;
bounds = null
circle = null
stage = null
circleXReset = 0
unit = 3
init = () ->
    #if not document.createElement('canvas').getContext
    #    wrapper = document.getElementById "canvasWrapper"
    #    wrapper.innerHTML = "Your browser does not support canvas"
    #    return    
    canvas = document.getElementById "board"
    bounds = new Rectangle()
    bounds.width = canvas.width
    bounds.height = canvas.height
    stage = new Stage(canvas)
    g = new Graphics()
    g.setStrokeStyle(3)
    g.beginStroke Graphics.getRGB 255, 255, 255, .7
    g.drawCircle 0, 0, CIRCLE_RADIUS
    circle = new Shape g
    circle.x = canvas.width / 2
    circle.y = canvas.height / 2
    stage.addChild circle
    stage.update()
    Ticker.setFPS 25
    Ticker.addListener this

tick = () ->
    if circle.y > bounds.height || circle.y < 0
        unit = -unit
    circle.x += unit
    circle.y += unit
    stage.update()
###

class BoardAnimation
    stage: {}
    tickSizeX: 0
    tickSizeY: 0
    
    constructor: () ->

    tick: () ->
        if (signal.x < path.x1 and signal.y < path.y1) or (signal.x > path.x2 and signal.y > path.y2)
                @tickSizeX = -@tickSizeX
                @tickSizeY = -@tickSizeY
        signal.x += @tickSizeX
        signal.y += @tickSizeY
        @stage.update()

class BoardDrawer
    margin: 100
    size: 40
    horIncrement: 0
    verIncrement: 0
    diffRows: 0

    init: () ->
        @horIncrement = Math.ceil Math.sqrt(3)*@size/2
        @verIncrement = Math.ceil 3*@size/2
        @diffRows = @maxRow - @minRow
        @stage.enableMouseOver()

    constructor: (@id, @stage, @minRow, @maxRow) ->
        init()

    getPoint: (i, j) ->
        offset = @margin + Math.abs(@diffRows - j)*@horIncrement
        x = getOffset(j) + 2*i*@horIncrement
        y = @margin + j*@verIncrement
        new Point(x, y)

    drawHex: (point, fieldState) ->
        drawStroke(point)
        drawOwnership(point, fieldState.owner)
        drawPlatform(point, fieldState.field.platform)
        drawResource(point, fieldState.field.resource)
        setBacklight(point)

    drawPlatform: (point, platform) ->
        g = new Graphics()
        switch platform
            when 1 then g.beginFill("#A6B4B0")
        g.drawPolyStar(point.x, point.y, @size/2, 6, 0, 90)
        @stage.addChild new Shape g

    drawStroke: (point) ->
        g = new Graphics()
        g.beginStroke("#616166")
            .setStrokeStyle(3)
            .drawPolyStar(point.x, point.y, @size, 6, 0, 90)
        @stage.addChild new Shape g

    drawOwnership: (point, owner) ->
        g = new Graphics()
        switch owner
            when 0 then g.beginFill("#000000")
            when 1 then g.beginFill("#274E7D")
            when 2 then g.beginFill("#A60C00")
            else
        g.drawPolyStar(point.x, point.y, @size, 6, 0, 90)
        @stage.addChild new Shape g
    
    drawResource: (point, resource) ->
        g = new Graphics()
        switch resource
            when 1 then g.beginFill("#FFFFFF")
            when 2 then g.beginFill("#256025")
            else
        g.drawCircle(point.x, point.y, 6)
        @stage.addChild new Shape g


    drawChannel: (point, channelState) ->
        g = new Graphics()
        x = point.x
        y = point.y
        switch channelState.routing
            when 0 then (x -= @horIncrement
            y -= @verIncrement)
            when 1 then (x += @horIncrement
            y -= @verIncrement)
            when 2 then x += 2*@horIncrement
            when 3 then (x += @horIncrement
            y += @verIncrement)
            when 4 then (x -= @horIncrement
            y += @verIncrement)
            when 5 then x -= 2*@horIncrement
        g.moveTo(point.x, point.y)
            .setStrokeStyle(3)
            .beginStroke("#FFFF00")
            .beginFill("#FFFF00")
            .lineTo(x, y)
        @stage.addChild new Shape g

    drawSignal: (point) ->
        g = new Graphics()
        g.setStrokeStyle(1)
            .beginStroke("#FFFF00")
            .drawCircle(point.x, point.y, 8)
        @stage.addChild new Shape g

    setBacklight: (point) ->
        g = new Graphics()
        g.drawPolyStar(point.x, point.y, @size, 6, 0, 90)
        overlay = new Shape g
        overlay.onMouseOver = mouseOverField
        @stage.addchild overlay

    mouseOverField: (event) ->
        g = new Graphics()
        g.beginStroke("#ED903E")
            .setStrokeStyle(3)
            .drawPolyStar(event.target.x, event.target.y, @size, 6, 0, 90)
        overlay = new Shape g
        overlay.onMouseOut = mouseOutField
        @stage.addchild overlay

    mouseOutField: (event) ->
        @stage.removeChild(event.target)

    mouseOnClickRadial: (event) ->

#---------------Interface---------------#

    createPlatfrom: (i, j, fieldState)->
        point = getPoint(i, j)
        drawOwnership(point, fieldState.owner)
        drawPlatform(point, fieldState.field.platform)
        @stage.update()

    createChannel: (i, j, channelState) -> 
        point = getPoint(i, j)
        drawOwnership(point, channelState.owner)
        drawChannel(point, channelState.routing)
        @stage.update()

    createResource: (i, j, fieldState) ->
        point = getPoint(i, j)
        drawResource(point, fieldState.field.resource)
        @stage.update()

    drawState: (boardState) ->      
        for j in [0 ... (2*@diffRows + 1)]
            for i in [0 ... @maxRow - Math.abs(@diffRows - j)]
                point = getPoint(i, j)
                @drawHex(point, boardState.fields.get(i, j))
                for channel in boardState.channels.get(i,j)
                    @drawChannel(point, channel)
        @stage.update()

$ ->
    if $("#board").length > 0
        ( ->
            canvas = document.getElementById "board"
            stage = new Stage canvas
            state = new BoardState 1
            drawer = new BoardDrawer 1, stage, 4, 9
            state.draw()
        )()


#grid1 = [[2,1],[2,1,2],[2,1]]
#grid2 = [[1,1,2,2],[1,2,2,2,1],[1,2,1,2,1,2],[2,1,2,2,2,1,1],[2,2,1,1,1,2,1,2],[1,1,1,2,2,1,2,1,1],[2,2,1,1,1,2,1,2],[2,1,2,2,2,1,1],[1,2,1,2,1,2],[1,2,2,2,1],[1,1,2,2]]


###
margin = 100
size = 30
count = 12
height = Math.ceil 2*margin+(3*count+1)/2*size
width = 2*margin+Math.ceil(Math.sqrt(3)*size/2)*25
tickSize = 5
stage = null
horIncrement = Math.ceil Math.sqrt(3)*size/2
verIncrement = Math.ceil 3*size/2
view = {}
signal = {}
path = {}

minRow = 4
maxRow = 9
diffRows = maxRow - minRow

tickSizeX = 0
tickSizeY = 0


init = () ->
    canvas = document.getElementById "board"
    bounds = new Rectangle()
    bounds.width = canvas.width
    bounds.height = canvas.height
    stage = new Stage canvas
    drawBoard()
    m = new Point margin+Math.abs(diffRows - 2)*horIncrement+2*horIncrement, margin
    n = new Point margin+Math.abs(diffRows + 2)*horIncrement+2*horIncrement, margin+4*verIncrement  
    path = drawLine m, n
    signal = drawOval()
    signal.x = m.x
    signal.y = m.y
    stage.addChild path
    stage.addChild signal
    stage.update()
    tickSizeX = Math.abs(path.x2 - path.x1)/48
    tickSizeY = Math.abs(path.y2 - path.y1)/48
    Ticker.setFPS 24
    Ticker.addListener this

tick = () ->
    console.debug(path.x1)
    if (signal.x < path.x1 and signal.y < path.y1) or (signal.x > path.x2 and signal.y > path.y2)
            tickSizeX = -tickSizeX
            tickSizeY = -tickSizeY
    signal.x += tickSizeX
    signal.y += tickSizeY
    stage.update()

drawBoard = () ->
    offset = {}
    horIncrement = Math.ceil Math.sqrt(3)*size/2
    verIncrement = Math.ceil 3*size/2
    for j in [0 ... (2*diffRows + 1)]
        y = margin + j*verIncrement
        offset = margin + Math.abs(diffRows - j)*horIncrement
        for i in [0 ... maxRow - Math.abs(diffRows - j)]
            x = offset + 2*i*horIncrement
            hex = drawHex x, y, size
            stage.addChild hex
    stage.update()

drawHex = (x, y, size) ->
    g = new Graphics()
    g.beginStroke("#880000").beginFill("#808080").setStrokeStyle(3)
    g.drawPolyStar x, y, size, 6, 0, 90
    new Shape g

drawLine = (m, n) ->
    g = new Graphics()
    g.moveTo(m.x, m.y)
        .setStrokeStyle(3)
        .beginStroke("#FFFF00")
        .beginFill("#FFFF00")
        .lineTo(n.x, n.y)
    path = new Shape g
    path.x1 = m.x
    path.y1 = m.y
    path.x2 = n.x
    path.y2 = n.y
    path

drawOval = () ->
    g = new Graphics()
    g.setStrokeStyle(1)
        .beginStroke("#FFFF00") 
        .drawCircle(0, 0, 8)
    signal = new Shape g

$ -> 
    if $("#board").length > 0
        init()
###
