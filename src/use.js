import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';

import {getEnv} from './manager';
import startShell from './startShell';

// given a 
export default function use(project) {
  return getEnv(project).then(([vars, project]) => {
    return startShell(project, vars);
  });
}
