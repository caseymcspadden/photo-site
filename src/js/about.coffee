$ = require 'jquery'
require 'foundation'
require 'cropper'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

$('body').append loginView.render().el

$('.crop-photo').cropper({
	viewMode: 2
	aspectRatio: 12 / 10,
	autoCropArea: 1,
	scalable: false,
	rotatable: false,
	zoomable: false,
	background: false,
	minCropBoxHeight: 300 
	crop: (e) ->
		#Output the result data for cropping image.
		console.log(e.x);
		console.log(e.y);
		console.log(e.width);
		console.log(e.height);
		#console.log(e.rotate);
		#console.log(e.scaleX);
		#console.log(e.scaleY);
});

session.fetch()

$(document).foundation()
