'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = init;

var _fsPromise = require('fs-promise');

var _fsPromise2 = _interopRequireDefault(_fsPromise);

var _bluebird = require('bluebird');

var _bluebird2 = _interopRequireDefault(_bluebird);

var _path = require('path');

var _path2 = _interopRequireDefault(_path);

var _untildify = require('untildify');

var _untildify2 = _interopRequireDefault(_untildify);

var _constants = require('./constants');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// try to find the local project name
const lookFor = {
  'package.json': contents => {
    let data = JSON.parse(contents);
    return data ? data.name : null;
  },
  'setup.py': contents => {
    let name = contents.match(/name[ ]+=[ ]+['"](.+)['"]/);
    return name ? name[1] : null;
  }
};
function getProjectName() {
  let findFirstMatch = [];
  for (let key in lookFor) {
    findFirstMatch.push(asyncCheck(_path2.default.join(process.cwd(), key), lookFor[key]));
    console.log(_path2.default.join(process.cwd(), key));
  }

  function asyncCheck(key, value) {
    return _fsPromise2.default.readFile(key).then(value);
  }

  return _bluebird2.default.any(findFirstMatch);
}

function init(project) {
  // step 0: determine project name
  if (typeof project !== "string") {
    return getProjectName().then(init);
  } else if (project.trim().length === 0) {
    console.error("No project name was specified or found. Please specify one manually.");
  } else {
    // step 1: write stuff to local Biomefile
    let biomeFile = _path2.default.join(process.cwd(), (0, _constants.biomeLocalName)());
    return _fsPromise2.default.writeFile(biomeFile, JSON.stringify({
      name: project
    }, null, 2)).then(file => {
      // step 2: write creds file in the ~/.biome folder
      let biomeProject = _path2.default.join((0, _constants.biomeFolderName)(), `${ project }.json`);
      return _fsPromise2.default.writeFile(biomeProject, "{}").then(f => project);
    });
  }
}