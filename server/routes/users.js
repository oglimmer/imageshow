const express = require('express');
const jwt = require('jsonwebtoken');

const db = require('../persistence/db');
const smtpProvider = require('../services/smtpProvider');
const configurableProperties = require('../services/configurableProperties');

const router = express.Router();

router.post('/', async (req, res, next) => {
  const { email: rawEmail, password } = req.body;
  const email = rawEmail.trim();
  const userObj = await db.loadUser(email);
  if (userObj) {
  	res.status(500).send({ error: 'Email already used' });
  	return;
  }
  db.createUser({ email, password });
  const confirmObj = await jwt.sign({ email },
    configurableProperties.createUserConfirmEncPassword, { expiresIn: '24h' });
  const confirmLink = `${configurableProperties.baseUrl}/api/v1/auth/confirm/${confirmObj}`;
  res.send({ returnCode: 101 });
  smtpProvider.send({
  	to: email,
  	subject: 'IMAGE_SHOW: Confirm your email address',
  	body: `Hi,
\n
Click here to accept the terms and conditions of IMAGE_SHOW and confirm your email address:
${confirmLink}
(This link is valid for 24h)
\n
Regards,
Oli ;)`
  });
});

module.exports = router;
