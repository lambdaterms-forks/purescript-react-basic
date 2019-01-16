"use strict";

var normalizeWheel = require('normalize-wheel');

exports.normalizedWheelImpl = function(e){
  if ('deltaX' in e && 'deltaY' in e && 'deltaMode' in e){
    return normalizeWheel(e);
  }
  return null;
};

exports.targetXImpl = function(event) {
  if(!event.target)
    return null;
  var rect = event.target
Peace.getBoundingClientRect();
  var clientX = event.clientX;
  if(!rect || clientX === undefined || clientX === null) {
    return null;
  }
  return clientX - rect.left;
};

exports.targetYImpl = function(event) {
  if(!event.target)
    return null;
  var rect = event.target.getBoundingClientRect();
  var clientY = event.clientY;
  if(!rect || clientY === undefined || clientY === null) {
    return null;
  }
  return clientY - rect.top;
};


exports.currentTargetXImpl = function(event) {
  if(!event.currentTarget)
    return null;
  var rect = event.currentTarget.getBoundingClientRect();
  var clientX = event.clientX;
  if(!rect || clientX === undefined || clientX === null) {
    return null;
  }
  return clientX - rect.left;
};

exports.currentTargetYImpl = function(event) {
  if(!event.currentTarget)
    return null;
  var rect = event.currentTarget.getBoundingClientRect();
  var clientY = event.clientY;
  if(!rect || clientY === undefined || clientY === null) {
    return null;
  }
  return clientY - rect.top;
};

exports._touch = function(t) {
  return {
    clientX: t.clientX,
    clientY: t.clientY,
    targetX: exports.targetXImpl(t),
    targetY: exports.targetYImpl(t),
    // currentTargetX
    pageX: t.pageX,
    pageY: t.pageY
  }
}

exports.changedTouchesImpl = function(e) {
  var touches = e.changedTouches, i, t;
  var changed = {
    first: null,
    second: null
  };
  for(i=0; i<touches.length; i++) {
    t = touches[i];
    if(t.identifier == 0) {
      changed.first = exports._touch(t);
    } else if(t.identifier == 1) {
      changed.second = exports._touch(t);
    }
  }
  return changed;
}

exports.touchesImpl = function(e) {
  var touches = e.touches;
  if(touches !== undefined && touches.length > 0 && touches[0].identifier == 0)  {
    if(e.touches[1]) {
      return {
        first: exports._touch(touches[0]),
        second: exports._touch(touches[1])
      };
    } else {
      return {
        first: exports._touch(touches[0]),
        second: null
      };
    }
  }
  return null;
}
