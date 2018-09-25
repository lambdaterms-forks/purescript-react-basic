"use strict";

// exports.getBoundingClientRect = function(eventTarget){
//   return eventTarget.getBoundingClientRect();
// };


exports.getTargetX = function(e){
  const bb = e.target.getBoundingClientRect();
  return e.clientX - bb.left;
};

exports.getTargetY = function(e){
  const bb = e.target.getBoundingClientRect();
  return e.clientY - bb.top;
};
