Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	#events:
		#'click .scroll-left' : 'scrollLeft'
		#'click .scroll-right' : 'scrollRight'
		#'click input:radio[name=view-size]' : 'changeImageSize'
		#'keydown' : 'keyDown'

	initialize: (options) ->
		this.counter = 0
		this.template = templates['slideshow-view']
		this.slideTemplate = templates['slide-view']
		#this.render()
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	addOne: (m) ->
		json = m.toJSON()
		console.log json
		json.position = this.counter++
		json.urlBase = config.urlBase
		this.$el.append this.slideTemplate(json) 
		#this.$('.controls').before this.slideTemplate(json) 

	addAll: ->
		this.$el.html ''
		this.counter = 0
		this.collection.each this.addOne, this
		this.counter = 0
		this.showCurrent 0

	showCurrent: (i) ->
		this.counter = this.counter + i
		this.counter = 0 if this.counter >= this.collection.length
		this.counter = this.collection.length-1 if this.counter < 0
		this.$('.slide img').removeClass('show')
		this.$('#slide-'+this.counter+' img').addClass('show')

	#injectControls: ->

	#autoCycle: (speed, pauseOnHover) ->

	#addFullScreen: ->

	#addSwipe: ->

	#toggleFullScreen: ->


