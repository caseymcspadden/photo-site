BaseView = require './base-view'
templates = require './jst'
config = require './config'
Instafeed = require 'instafeed.js'

module.exports = BaseView.extend
	events:
		'click .header a' : 'animate'

	initialize: (options) ->
		this.template = templates['instagram-view']
		this.opened = false;

	render: ->
		this.$el.html this.template		
		feed = new Instafeed(
			get: 'user',
			userId: '727575',
			accessToken: '727575.6a15ce4.e9e018e14ae64aa1b2d7a48e9b580416'
			sortBy: 'most-recent'
			limit: 9
			template: '<div class="photo-container"><a href="{{link}}"><img src="{{image}}" /></a><div class="info">{{caption}}</div></div>'
		)
		feed.run()

	animate: ->
		if this.opened
			this.$('.container').animate({opacity: 0} , "slow")
		else
			this.$('.container').animate({opacity: 1} , "slow")
		this.opened = !this.opened
	###
	animate: ->
		if this.opened
			this.$('.container').animate({'max-height': '0px'} , "slow")
		else
			this.$('.container').animate({'max-height': '500px'} , "slow")
		this.opened = !this.opened
	###
