require('../css/reset.css');
require('../css/bootstrap.min.css');
require('../../elm/src/Stylesheets.elm');

/* Kids: don't try this at home! It's bad for you!!
  Only do it if you are in a Hackton and you don't
  really have time for quality and best practices
  mambo jambo right now. :D
*/
document.mainElm = require('../../elm/src/Main.elm');
document.fakeValvesElm = require('../../elm/src/FakeValvesMain.elm');
