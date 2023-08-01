# KystParallax

Custom View with parallax effect that can be used on MacOS and IOS. 

Project-sample of use:https://github.com/Kyst2/ParallaxView

How it looks on MacOS:
==

[![enter image description here][1]][1]


  [1]: https://i.stack.imgur.com/c1xhm.gif

How it looks on iOS:
==

--//--


How to use MacOS:
==
```
ZStack {
   ParallaxLayer(image: Image("depth-1"), speed: 15 )
   ParallaxLayer(image: Image("depth-2"), speed: 35 )
   ParallaxLayer(image: Image("depth-3"), speed: 55)
}
```

How to use iOS:
==
```
ZStack {
    ParallaxLayer(image: Image("depth-1"), magnitude : 10)
    ParallaxLayer(image: Image("depth-2"), magnitude : 30)
    ParallaxLayer(image: Image("depth-3"), magnitude : 50)
}
```



