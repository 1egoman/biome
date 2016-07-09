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

// # run this after every cd
// [[ -f /tmp/sourcefrombiome ]] && source /tmp/sourcefrombiome && rm /tmp/sourcefrombiome
export function source(project) {
  return getEnv(project).then(([vars, project]) => {
    // turn make all the variables into a string
    let shellVars = `
# Biome config
export BIOME_SHELL=true
export BIOME_PROJECT="${project}"
export BIOME_NVARS="${Object.keys(vars).length}"\n
# Project variables
`.trim() + '\n';
    for (let variable in vars) {
      shellVars += `export ${variable}="${vars[variable]}"\n`;
    }

    // write to tmp
    return fs.writeFile(path.join("/", "tmp", "sourcefrombiome"), shellVars);
  });
}
