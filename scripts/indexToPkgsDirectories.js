#!/usr/local/bin/node

const fs = require('fs');

var agsModules = JSON.parse(fs.readFileSync('../index/package_index.json', 'utf8'));

for (var i in agsModules){
	
	var pkg = agsModules[i];
	var dir = "../pkgs/"+pkg.id;
	
	console.log(pkg);
	
	if (!fs.existsSync(dir)){
		fs.mkdirSync(dir);
	}

	fs.writeFile(dir+"/package.json", JSON.stringify(pkg, null, 2), function(err) {
		if(err) {
			return console.log(err);
		}

		console.log("The file was saved!");
	}); 	
}