const path = require('path');
module.exports = {
  plugins: [path.join(__dirname, 'prettier-plugins/node_modules/prettier-plugin-astro/dist/index.js')],
};
