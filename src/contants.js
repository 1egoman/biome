import path from 'path';
import home from 'user-home';

// The file that is in each individual project. Defaults to Biomefile.
export function biomeLocalName() {
  return process.env.BIOME_LOCAL_NAME || 'Biomefile';
}

// The folder that contains all the individual configs. Defaults to ~/.biome
export function biomeFolderName() {
  return path.normalize(process.env.BIOME_FOLDER_NAME || '~/.biome');
}

