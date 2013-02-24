var fs = require("fs");
var path = require("path");
var argparse =  require( "argparse" );
var uglify = require("uglify-js2");
var execSync = require('exec-sync');
var spawn = require('child_process').spawn;

var base = "../sources/";
var coffeedir = base+"shdr/";
var files = [
	base+"/libs/threejs/three.min.js",
	base+"/libs/threejs/three.orbit.js",
	base+"/libs/threejs/three.webglrenderer.custom.js",
	base+"/libs/ace/ace.js",
	base+"/libs/zip/rawdeflate.js",
	base+"/libs/zip/rawinflate.js",
	base+"/libs/jquery-1.8.js",
	base+"shdr/App.js",
	base+"shdr/Models.js",
	base+"shdr/Snippets.js",
	base+"shdr/UI.js",
	base+"shdr/Validator.js",
	base+"shdr/Viewer.js"
];

function main() {

	"use strict";

	var parser = new argparse.ArgumentParser();
	parser.addArgument(['--minify'], { action: 'storeTrue', defaultValue: false });
	parser.addArgument(['--output'], { defaultValue: 'shdr.js' });

	var args = parser.parseArgs();
	
	var output = args.output;
	console.log(' * Building ' + output);

	console.log(' * Compiling coffeescript classes from '+coffeedir);
	var comp = execSync('coffee -c '+coffeedir);
	console.log(comp);

	var buffer = [];
	var sources = [];

	console.log(' * Concating .js files');

	console.log(files);

	if(!args.minify)
	{
		for (var j = 0; j < files.length; j ++)
		{
			var file = files[j];
			sources.push(file);
			buffer.push(fs.readFileSync(file, 'utf8'));
		}

		var temp = buffer.join('');
		fs.writeFileSync(output, temp, 'utf8');
	} 
	else 
	{
		var result = uglify.minify(files, {});
		fs.writeFileSync(output, result.code, 'utf8');
	}

	console.log(' * Shdr was built to '+output);
}

main();
