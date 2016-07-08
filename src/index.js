#!/usr/bin/env node
import program from 'commander';

program.version('0.0.1');

// ----------------------------------------------------------------------------
// biome use
// ----------------------------------------------------------------------------
program
.command('use [project]')
.action(project => {
  console.log(req)
});

program.parse(process.argv);
