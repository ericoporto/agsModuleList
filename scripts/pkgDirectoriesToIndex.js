#!/usr/local/bin/node

const fs = require('fs');
const path = require('path');

function getDirList(search_path){
	function getDirectories(srcpath) {
	  return fs.readdirSync(srcpath)
		.map(file => path.join(srcpath, file))
		.filter(path => fs.statSync(path).isDirectory());
	}
	var res = getDirectories(search_path); 
	res = res.map(function(x){ return x.replace(/\\/g,"/") }); 
	return res;
}

var pkg_dirs = getDirList("../pkgs/");

pkglist = [];
for(var i in pkg_dirs){
	var pkgdir = pkg_dirs[i];
	
	var pkg = JSON.parse(fs.readFileSync(pkgdir+"/package.json", 'utf8'));
	pkglist.push(pkg);
	console.log("read package:"+pkg.id);
}

fs.writeFile("../index/package_index.json", JSON.stringify(pkglist, null, 2), function(err) {
	if(err) {
		return console.log(err);
	}

	console.log("The file was saved!");
}); 

