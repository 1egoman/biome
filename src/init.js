import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';
import untildify from 'untildify';

import {biomeLocalName, biomeFolderName} from './constants';

// try to find the local project name
const lookFor = {
  'package.json': contents => {
    let data = JSON.parse(contents);
    return data ? data.name : null;
  },
  'setup.py': contents => {
    let name = contents.match(/name[ ]+=[ ]+['"](.+)['"]/);
    return name ? name[1] : null;
  },
};
function getProjectName() {
  let findFirstMatch = [];
  for (let key in lookFor) {
    findFirstMatch.push(asyncCheck(path.join(process.cwd(), key), lookFor[key]));
    console.log(path.join(process.cwd(), key))
  }

  function asyncCheck(key, value) {
    return fs.readFile(key).then(value);
  }

  return Promise.any(findFirstMatch);
}

export default function init(project) {
  // step 0: determine project name
  if (typeof project !== "string") {
    return getProjectName().then(init);
  } else if (project.trim().length === 0) {
    console.error("No project name was specified or found. Please specify one manually.");
  } else {
    // step 1: write stuff to local Biomefile
    let biomeFile = path.join(process.cwd(), biomeLocalName());
    return fs.writeFile(
      biomeFile,
      JSON.stringify({
        name: project,
      }, null, 2)
    ).then(file => {
      // step 2: write creds file in the ~/.biome folder
      let biomeProject = path.join(biomeFolderName(), `${project}.json`);
      return fs.writeFile(biomeProject, "{}").then(f => project);
    });
  }
}
