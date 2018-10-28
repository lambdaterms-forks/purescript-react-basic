"use strict";

var normalizeWheel = require('normalize-wheel');


exports.getTargetX = function(e){
  const bb = e.target.getBoundingClientRect();
  return e.clientX - bb.left;
};

exports.getTargetY = function(e){
  const bb = e.target.getBoundingClientRect();
  return e.clientY - bb.top;
};

exports.computeNormalizedWheel = function(e){
  if ('deltaX' in e && 'deltaY' in e && 'deltaMode' in e){
    return normalizeWheel(e);
  }
  return null;
};
