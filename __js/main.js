var idx = lunr(function () {
  this.ref('id')
  this.field('name')
  this.field('id')
  this.field('text')
  this.field('author')
  this.field('keywords')

  agsModules.forEach(function (doc) {
    this.add(doc)
  }, this)
})



