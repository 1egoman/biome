import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';

import {biomeLocalName} from './contants';

// get the project metadata (name) of the project in the cwd,
// or if specified, a custom directory.
export function getProjectMetadata(cwd=process.cwd()) {
  let biomeFile = path.join(cwd, biomeLocalName());
  return fs.readJson(biomeFile);
}
