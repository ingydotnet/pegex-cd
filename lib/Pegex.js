// Generated by CoffeeScript 1.3.3
(function() {
  var Grammar, Receiver, pegex;

  exports.VERSION = '0.19';

  Grammar = require('./Pegex/Grammar');

  Receiver = require('./Pegex/Receiver');

  pegex = function(grammar, options) {
    var receiver, wrap, _ref, _ref1;
    options || (options = {});
    wrap = (_ref = options.wrap) != null ? _ref : true;
    receiver = (_ref1 = options.receiver) != null ? _ref1 : new Receiver(wrap);
    return new Grammar(grammar, receiver);
  };

  exports.pegex = pegex;

}).call(this);