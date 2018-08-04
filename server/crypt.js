const jwt = require('jsonwebtoken');

const configurableProperties = require('./services/configurableProperties');

jwt.sign({ email: process.argv[2] },
  configurableProperties.createUserConfirmEncPassword, { expiresIn: '24h' }, (err, confirmObj) => {
    console.log(`${configurableProperties.baseUrl}/api/v1/auth/confirm/${confirmObj}`);
  });
