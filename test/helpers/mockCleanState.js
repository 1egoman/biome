import fs from 'fs';
import path from 'path';
import mockFs from 'mock-fs';
import untildify from 'untildify';

export default function mockCleanSlate() {
  let home = untildify('~/');
  return mockFs({
    [home]: {
      '.biome': {
        'project.json': '{}',
      },
    },
    [process.cwd()]: {
      'Biomefile': JSON.stringify({name: "project"}),
    },
  }, {createCwd: false});
}

export function mockEmptyState() {
  let home = untildify('~/');
  return mockFs({
    [home]: {
      '.biome': {},
    },
    [process.cwd()]: {},
  }, {createCwd: false});
}
