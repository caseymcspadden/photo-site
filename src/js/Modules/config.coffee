Config = ->

Config.prototype.urlBase = 'http://caseymcspadden'
Config.prototype.servicesBase = 'http://caseymcspadden/bamenda'
Config.prototype.adminBase = 'http://caseymcspadden/mamfe'

###
Config.prototype.urlBase = 'https://caseymcspadden:8890'
Config.prototype.servicesBase = 'https://caseymcspadden:8890/bamenda'
Config.prototype.adminBase = 'https://caseymcspadden:8890/mamfe'
###

###
Config.prototype.urlBase = 'https://www.caseymcspadden.com'
Config.prototype.servicesBase = 'https://www.caseymcspadden.com/bamenda'
Config.prototype.adminBase = 'https://www.caseymcspadden.com/mamfe'
###

###
Config.prototype.urlBase = 'https://192.168.7.66:8890'
Config.prototype.servicesBase = 'https://192.168.7.66:8890/bamenda'
Config.prototype.adminBase = 'https://192.168.7.66:8890/mamfe'
###
module.exports = new Config
