// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

var menuAttached = false;
var handleMenu = function() {
  if (menuAttached) { return; }
  var menu = document.querySelector('.js-menu');
  if (!menu) { return; }

  // Prevent propagation pass menu
  menu.addEventListener('click', function(e) {
    e.stopPropagation();
  });
  // Toggle employer app menu
  document.querySelector('.menuIcon.js-trigger').addEventListener('click', function(e) {
    e.stopPropagation();
    menu.classList.toggle('is-in');
  });
  // Click outside to exit app menu
  document.querySelector('main').addEventListener('click', function(e) {
    menu.classList.remove('is-in');
  });

  menuAttached = true;
};

document.addEventListener('DOMContentLoaded', handleMenu);
window.onresize = function() {
  handleMenu();
};
