var idx = lunr(function () {
  this.ref('name')
  this.field('text')

  agsModules.forEach(function (doc) {
    this.add(doc)
  }, this)
})



