var fs = require("fs");
var path = require("path");
var argparse =  require( "argparse" );
var uglify = require("uglify-js");
var execSync = require('exec-sync');
var spawn = require('child_process').spawn;

var base = "../sources/";
var coffeedir = base+"shdr/";
var minifiedlibs = [
	base+"libs/ace/ace.js",
	base+"libs/ace/mode-glsl.js",
	base+"libs/threejs/three.min.js",
	base+"libs/jquery-1.8.js"
];
var files = [
	base+"libs/ace/theme-monokai.js",
	base+"libs/threejs/three.orbit.js",
	base+"libs/threejs/three.webglrenderer.custom.js",
	base+"libs/zip/rawdeflate.js",
	base+"libs/zip/rawinflate.js",
	base+"shdr/App.js",
	base+"shdr/Models.js",
	base+"shdr/Snippets.js",
	base+"shdr/Storage.js",
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
	var minlibs = "";

	console.log(' * Merging minified libs');
	for(var i = 0; i < minifiedlibs.length; i++)
	{
		minlibs += fs.readFileSync(minifiedlibs[i], 'utf8');
	}

	console.log(' * Concating .js files');

	console.log(files);

	if(!args.minify)
	{
		for(var j = 0; j < files.length; j++)
		{
			var file = files[j];
			sources.push(file);
			buffer.push(fs.readFileSync(file, 'utf8'));
		}

		var temp = buffer.join('');
		fs.writeFileSync(output, minlibs+temp, 'utf8');
	} 
	else 
	{

		console.log(' * Minifying...');
		var result = uglify.minify(files, {});
		fs.writeFileSync(output, minlibs+result.code, 'utf8');
	}

	console.log(' * Shdr was built to '+output);
}

main();
