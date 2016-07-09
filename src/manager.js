import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';
import home from 'user-home';

import {biomeFolderName} from './contants';
import {getProjectMetadata} from './local';

// get the project metadata (name) of the project in the cwd,
// or if specified, a custom directory.
export function findVariablesFor(project) {
  let biomeProject = path.join(biomeFolderName(), `${project}.json`);
  return fs.readJson(biomeProject);
}

// given a project, return the associated environment vars
export function getEnv(project) {
  return getProjectMetadata(project).then(meta => { // get local Biomefile
    console.log(`Found Biomefile for ${meta.name}...`);
    return Promise.all([findVariablesFor(meta.name), meta.name]);
  });
}
