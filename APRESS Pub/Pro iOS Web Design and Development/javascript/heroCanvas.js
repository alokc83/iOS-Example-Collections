var imagePaths = [
	"pics/hero-slide_01.png", "pics/hero-slide_02.png", "pics/hero-slide_03.png"
];
var showCanvas = null;
var showCanvasCtx = null;
var img = document.createElement("img");
var currentImage = 0;

function switchImage() {
	img.setAttribute('src',imagePaths[currentImage++]);
	img.onload = function() {
		if (currentImage >= imagePaths.length)
			currentImage = 0;
		
		showCanvasCtx.drawImage(img,0,0,298,150);
	}
}

window.onload = function () {
	showCanvas = document.getElementById('heroCanvas');
	showCanvasCtx = showCanvas.getContext('2d');
	
	img.setAttribute('width','298');
	img.setAttribute('height','150');
	switchImage();
	
	setInterval(switchImage,2500);
}