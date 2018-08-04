const jwt = require('jsonwebtoken');
const configurableProperties = require('../services/configurableProperties');

module.exports = {
  createAccessTokenObj: async userRef => {
    const expires_in_server = 3600;
    const expires_in = expires_in_server - 30;
    const access_token = await jwt.sign({ userRef },
      configurableProperties.accessTokenEncPassword, { expiresIn: `${expires_in}s` });
    return { access_token, expires_in };
  } 
};
