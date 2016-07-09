import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';

import {biomeLocalName, biomeFolderName} from './constants';

// given a 
export default function init(project) {
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
    return fs.writeFile(biomeProject, "{}");
  });
}
