var yaml = require('js-yaml')
  , fs = require('fs');

module.exports = yaml.load(fs.readFileSync('../../../config/database.yaml','utf-8'))['production']
