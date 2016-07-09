import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';

import {getEnv} from './manager';
import startShell from './startShell';

// given a project, open a subshell with its associated variables
export default function use(project) {
  return getEnv(project).then(([vars, project]) => {
    return startShell(project, vars);
  });
}
