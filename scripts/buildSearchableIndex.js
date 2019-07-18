#!/usr/local/bin/node

const lunr = require('lunr');
const fs = require('fs');

var agsModules = JSON.parse(fs.readFileSync('../index/package_index.json', 'utf8'));

var idx = lunr(function () {
  this.ref('id')
  this.field('name')
  this.field('id')
  this.field('text')
  this.field('author')

  agsModules.forEach(function (doc) {
    this.add(doc)
  }, this)
})

fs.writeFile("../index/serializedSearcheableIndex.json", JSON.stringify(idx, null, 1), function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
}); 