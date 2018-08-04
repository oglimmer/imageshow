const express = require('express');
const jwt = require('jsonwebtoken');
const { promisify } = require('util');
const bcrypt = require('bcryptjs');
const debug = require('debug')('api:auth');

const db = require('../persistence/db');
const authenticationProvider = require('../services/authenticationProvider');
const configurableProperties = require('../services/configurableProperties');

const bcryptCompare = promisify(bcrypt.compare);

const router = express.Router();

const parallelLoginsIP = {};
const parallelLoginsEmail = {};

router.get('/confirm/:emailObj', async (req, res, next) => {
  const { emailObj } = req.params;
  try {
    const decodedObj = await jwt.verify(emailObj, configurableProperties.createUserConfirmEncPassword);
    const email = decodedObj.email;
    const userObj = await db.loadUser(email);
    if (!userObj.emailConfirmationDate) {
      userObj.emailConfirmationDate = new Date();
      await db.storeObject(userObj);
    }
    res.render('confirm', { email });
  } catch (err) {
    res.status(403).send({});
  }
});

function createError(code, obj, delay) {
  const err = new Error();
  err.retCode = code;
  err.retObj = obj;
  err.delay = delay;
  return err;
}

function validateInput({ grant_type, email, password, client_id }) {
  if (grant_type !== 'password') {
    throw createError(500, { error: `Unsupported grant_type: ${grant_type}` });
  }
  if (client_id !== 'genuine-web-client') {
    throw createError(500, { error: `Unsupported client_id: ${client_id}` });
  }
  if (!email) {
    throw createError(500, { error: 'email must not be empty' });
  }
  if (!password) {
    throw createError(500, { error: 'Password must not be empty' });
  }
}

function lockIPandEmail({ ipAddress, email }) {
  if (parallelLoginsIP[ipAddress]) {
    throw createError(403, {});
  }
  parallelLoginsIP[ipAddress] = true;

  if (parallelLoginsEmail[email]) {
    throw createError(403, {});
  }
  parallelLoginsEmail[email] = true;
}

function unlockIPandEmail({ ipAddress, email }) {
  delete parallelLoginsIP[ipAddress];
  delete parallelLoginsEmail[email];
}

async function checkPass({ userObj, password }) {
  let authSuccess = false;
  if (userObj) {
    if (await bcryptCompare(password, userObj.passwordHash)) {
      authSuccess = true;
    }
    let notSaved = true;
    while (notSaved) {
      try {
        if (authSuccess) {
          userObj.lastLogin = new Date();
          userObj.lastFailedLogin = null;
          userObj.failedLoginCount = 0;
        } else {
          userObj.lastFailedLogin = new Date();
          userObj.failedLoginCount += 1;
        }
        await db.storeObject(userObj);
        notSaved = false;
      } catch (err) {
        console.log(err);
      }
    }
  }
  return authSuccess;
}


function baseSleep(delay, callback) {
  setTimeout(_ => { callback(); }, delay);
}
const promiseBaseSleep = promisify(baseSleep);
async function sleep(delay) {
  await promiseBaseWait(delay);
}

function handleFailure({ userObj }) {
  const delay = userObj ? (userObj.failedLoginCount - 1) * 1000 : 0;
  throw createError(403, { error: 'Wrong user or password' }, delay);
}

function handleSuccessButNotConfirmatedEmail(res) {
  res.send({ returnCode: 101 });
}

async function handleSuccess({ userRef, res }) {
  const tokenObj = await authenticationProvider.createAccessTokenObj(userRef);
  res.send(tokenObj);
}

router.post('/token', async (req, res, next) => {
  const { grant_type, email, password, client_id } = req.body;
  const ipAddress = req.ip;
  try {
    validateInput({ grant_type, email, password, client_id });

    lockIPandEmail({ ipAddress, email });

    const userObj = await db.loadUser(email);

    if (!await checkPass({ userObj, password })) {
      handleFailure({ userObj });
    } else if (!userObj.emailConfirmationDate) {
      handleSuccessButNotConfirmatedEmail(res);
    } else {
      await handleSuccess({ userRef: userObj._id, res });
    }
  } catch (err) {
    debug('Error in auth. Code=%s with %o', err.retCode, err.retObj);
    if (err.delay) {
      await sleep(err.delay);
    }
    res.status(err.retCode).send(err.retObj);
  } finally {
    unlockIPandEmail({ ipAddress, email });
  }
});

module.exports = router;
