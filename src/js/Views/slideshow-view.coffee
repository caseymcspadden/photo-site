Backbone = require 'backbone'
Hammer = require 'hammerjs'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	events:
		'mouseover' : 'mouseOver'
		'mouseout' : 'mouseOut'
		'click .prev' : 'previous'
		'click .next' : 'next'
		#'click input:radio[name=view-size]' : 'changeImageSize'
		#'keydown' : 'keyDown'

	initialize: (options) ->
		this.counter = 0
		this.pauseOnHover = options.pauseOnHover
		this.speed = options.speed
		this.showControls = options.showControls
		this.addSwipe()
		this.controlsTemplate = templates['slideshow-view']
		this.slideTemplate = templates['slide-view']
		this.listenTo this.collection, 'reset', this.addAll

	#render: ->
	#	this.$el.html this.template()

	mouseOver: (e) ->
		if this.pauseOnHover
			this.interval = window.clearInterval this.interval

	mouseOut: (e) ->
		if this.pauseOnHover
			self = this
			this.interval = window.setInterval( ->
				self.showCurrent(1)
			, this.speed)

	previous: ->
		this.showCurrent -1

	next: ->
		this.showCurrent 1

	addOne: (m) ->
		json = m.toJSON()
		json.position = this.counter++
		json.urlBase = config.urlBase
		this.$el.append this.slideTemplate(json) 
		#this.$('.controls').before this.slideTemplate(json) 

	addAll: ->
		#this.$el.html ''
		this.counter = 0
		this.collection.each this.addOne, this
		this.counter = 0
		this.showCurrent 0
		this.autoCycle this.speed
		this.$el.append this.controlsTemplate() if this.showControls

	showCurrent: (i) ->
		this.counter = this.counter + i
		this.counter = 0 if this.counter >= this.collection.length
		this.counter = this.collection.length-1 if this.counter < 0
		this.$('.slide img').removeClass('show')
		this.$('#slide-'+this.counter+' img').addClass('show')

	#injectControls: ->

	autoCycle: (speed) ->
		self = this
		this.interval = window.setInterval( ->
			self.showCurrent(1)
		, this.speed)
 
	addSwipe: ->
		this.hammer = new Hammer(this.el)
		self = this
		this.hammer.on 'swiperight', (e) ->
			self.showCurrent(-1)

		this.hammer.on 'swipeleft', (e) ->
			self.showCurrent(1)

	#addFullScreen: ->


	#toggleFullScreen: ->


