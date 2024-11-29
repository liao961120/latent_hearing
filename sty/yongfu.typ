#let Math(doc) = [
  #set page(
    width: auto,
    height: auto, 
    margin: (x: 2pt, y: 2pt),
  )
  #set text(
    font: (
      "Adobe Caslon Pro", 
      "GFS Porson",
      "Georgia",
      "Libertinus Serif", 
      "New Computer Modern", 
      "New Computer Modern Math", 
      "DejaVu Sans Mono",
    )
  )
  #set math.equation(numbering: none)
  #doc
]

#let Math_num(width: 10cm, doc) = [
  #set page(
    width: width,
    height: auto, 
    margin: (x: 2pt, y: 2pt),
  )
  #set text(
    font: (
      "Adobe Caslon Pro", 
      "GFS Porson",
      "Georgia",
      "Libertinus Serif", 
      "New Computer Modern", 
      "New Computer Modern Math", 
      "DejaVu Sans Mono",
    )
  )
  #set math.equation(numbering: "(1)")
  // #show math.equation: set text(font: (
  //   // "New Computer Modern Math", 
  //   "Cambria Math"
  //   ) 
  // )
  #doc
]


// Utility Functions
#let red(x) = text(fill: rgb(255,0,0), $#x$)
#let green(x) = text(fill: rgb("#1e7e1e"), $#x$)
#let blue(x) = text(fill: rgb(0,0,255), $#x$)
#let up(x)  = math.upright(x)
