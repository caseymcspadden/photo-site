BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'click .header a' : 'animate'

	initialize: (options) ->
		this.template = templates['facebook-view']
		this.opened = false;

	render: ->
		this.$el.html this.template

	animate: ->
		if this.opened
			this.$('.container').animate({opacity: 0} , "slow")
		else
			this.$('.container').animate({opacity: 1} , "slow")
		this.opened = !this.opened



