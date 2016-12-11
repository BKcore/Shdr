Shdr
====

Shdr is an online ESSL (GLSL) shader editor, viewer and validator powered by WebGL.

> **Author:** [Thibaut Despoulain (BKcore)](http://bkcore.com)  
> **Version:** 0.1.130224

Inspired by MrDoob's live HTML editor.  
Powered by Three.js, Ace.js, RawDeflate.js and jQuery.  
Icons by AwesomeFont, Monkey head from Blender, HexMKII from HexGL.

Issues, feature requests, contributions:
[Fork me on GitHub!](https://github.com/BKcore/Shdr)

# Run
To test locally you don't need to build anything. The build step is only there for production and the chrome app.
```
cd source
python -m SimpleHTTPServer
chrome editor.html
```

# Build
If you want to test the prod version or the chrome app:
```
cd build
node build.js [--output=../source/build/shdr.js] [--minify] [--chromeapp] [--persist]
```

# Building and Running with npm
To install node and npm on Ubuntu:
```
sudo apt-get install nodejs npm
sudo ln -s /usr/bin/nodejs /usr/local/bin/node
```
To build and run with npm:
```
cd build
npm install
npm start
```
