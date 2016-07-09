#!/usr/bin/env node
import program from 'commander';

import use from './use';

program.version('0.0.1');

// ----------------------------------------------------------------------------
// biome use [project]
// ----------------------------------------------------------------------------
program
.command('use [project]')
.action(project => {
  use(project).catch(console.error.bind(console));
  // console.log(project)
});

program.parse(process.argv);
