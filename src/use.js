import fs from 'fs-promise';
import Promise from 'bluebird';
import path from 'path';

import {getEnv} from './manager';
import startShell from './startShell';

export default function use() {
  return getEnv().then(([vars, project]) => {
    return startShell(project, vars);
  });
}
