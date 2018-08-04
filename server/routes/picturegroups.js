const express = require('express');
const jwt = require('jsonwebtoken');

const db = require('../persistence/db');
const smtpProvider = require('../services/smtpProvider');
const authenticationProvider = require('../services/authenticationProvider');
const configurableProperties = require('../services/configurableProperties');

const router = express.Router();

async function getUserRef(authorization) {
  if (authorization && authorization.search(/^bearer /i) > -1) {
    const bearer = authorization.substring(7);
    const decodedBearer = await jwt.verify(bearer, configurableProperties.accessTokenEncPassword);
    return decodedBearer.userRef;
  }
  throw new Error('No or wrong Authorization header');
}

router.get('/', async (req, res, next) => {
  console.log('1');
  const { authorization } = req.headers;
  try {
    const userRef = await getUserRef(authorization);
    const pgObj = await db.loadPicturegroups(userRef);
    res.send(pgObj);
  } catch (err) {
    console.log(err);
    res.status(403).send({ error: err.message });
  }

});

router.get('/summary', async (req, res, next) => {
  console.log('2');
  const { authorization } = req.headers;
  try {
    const userRef = await getUserRef(authorization);
    const pgObj = await db.loadPicturegroupsSummary(userRef);
    console.log(pgObj);
    res.send(pgObj);
  } catch (err) {
    console.log(err);
    res.status(403).send({ error: err.message });
  }

});


module.exports = router;
