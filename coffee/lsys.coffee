window.go = () ->
  client = {down:false,start:{x:0,y:0}, now:{x:0,y:0}, context:{}}
  context = {}
  log = (x) -> console.log(x)
  control = (name) -> document.getElementById(name)
  value = (name) -> parseFloat(stringvalue(name))
  stringvalue = (name) -> control(name).value
  canvas = document.getElementById('c')
  g = canvas.getContext('2d')

      

  
  time = (n,f) -> 
    f = n if n instanceof Function
    s = new Date
    f()
    new Date - s

  clone = (c) -> {
    x:c.x,
    y:c.y,
    angle:c.angle,
    incAngle:c.incAngle,
    incLength:c.incLength
  }



  rules = stringvalue('rules').split("\n").map (rule) -> rule.split(" : ")
  iterations = value("num")

  rule = `{}`
  rule[r] = exp for [r,exp] in rules

  document.onkeydown = (ev) ->
    window.go() if ev.keyCode == 13 and ev.ctrlKey

  canvas.onmousedown = (ev) ->
    client.down = true
    client.context = {angle:parseFloat(value("angle")),length:parseFloat(value("length"))}
    client.start.x = ev.clientX
    client.start.y = ev.clientY

  canvas.onmouseup = -> client.down = false
  
  canvas.onmousemove = (ev) ->
    client.now.x = ev.clientX
    client.now.y = ev.clientY
    if (client.down)
      x = (client.now.x - client.start.x) / 20
      y = (client.start.y - client.now.y) / 100
      control("angle").value = x + client.context.angle
      control("length").value = y + client.context.length
      draw() if not isDrawing 



  stack = []
  cos = Math.cos
  sin = Math.sin
  fn = (g) ->
    len = context.incLength
    ang = ((context.angle%360) / 180) * Math.PI
    context.x = context.x+cos(ang)*len
    context.y = context.y+sin(ang)*len
    g.lineTo(context.x,context.y)
  functions = {
    "F": fn
    "A": fn
    "B": fn
    "+": -> context.angle += context.incAngle
    "-": -> context.angle -= context.incAngle
    "|": -> context.angle += 180
    "[": -> stack.push(clone context)
    "]": -> context = stack.pop(); g.moveTo(context.x,context.y)
    "!": -> context.incAngle *= -1
    "(": -> context.incAngle *= 0.95
    ")": -> context.incAngle *= 1.05
    "<": -> context.incLength *= 1.01
    ">": -> context.incLength *= 0.99
  }

  isDrawing = false
  draw = () ->
    isDrawing = true
    context = {
      x:canvas.width/2,
      y:canvas.height,
      angle:-90,
      incAngle:value("angle"),
      incLength:value("length")
    }
    start = rules[0][0]
    expr = start
    g.globalAlpha=1
    g.fillStyle="#202020"
    g.beginPath()
    g.rect(-1,-1,1000,1000)
    g.closePath()
    g.fill()
    g.lineWidth = 0.7
    g.strokeStyle="#fff"
    g.globalAlpha=0.4

    elems = []
    
    t = time ->
      expr = _.reduce expr.split(""), ((acc, symbol) ->
        acc + (rule[symbol] || symbol)
      ), "" for i in [1..iterations]

      elems = expr.split("")

    s = time -> 
      g.moveTo(context.x, context.y)
      _.each elems, (e) ->
        functions[e] && functions[e](g)
      g.stroke()

    control("rendered").innerText = t+"ms"
    control("segments").innerText = s+"ms"
    isDrawing = false

  draw()
#----------------------------------------#
  #time "rec version", ->
    #start = rule[rules[0][0]]
    #expr = start
    #stack = []
    #depth = 1
    #out=""
    #tot = 0
    #rec = (s,d) ->
      #_.each s.split(""), (el) ->
        #f = functions[el]
        #if d <= iterations
          #rec(rule[el]||el, d+1)
        #else
          #out += el
          #f(g) if f
    #g.beginPath()
    #rec(start, 1)
    #g.closePath()
    #g.stroke()
