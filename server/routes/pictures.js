const express = require('express');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');
const mkdirp = require('mkdirp-promise');
const { promisify } = require('util');
const { Entropy } = require('entropy-string');
const moment = require('moment');
const sharp = require('sharp');
const debug = require('debug')('api:pictures');

const db = require('../persistence/db');
const smtpProvider = require('../services/smtpProvider');
const authenticationProvider = require('../services/authenticationProvider');
const configurableProperties = require('../services/configurableProperties');

const writeFile = promisify(fs.writeFile);

const router = express.Router();
const entropy = new Entropy();

async function getUserRef(authorization) {
  if (authorization && authorization.search(/^bearer /i) > -1) {
    const bearer = authorization.substring(7);
    const decodedBearer = await jwt.verify(bearer, configurableProperties.accessTokenEncPassword);
    return decodedBearer.userRef;
  }
  throw new Error('No or wrong Authorization header');
}

router.get('/:uuid', async (req, res, next) => {
  const { uuid } = req.params;
  const { height } = req.query;

  const picObj = await db.loadPictureByUUID(uuid);

  const pathToFolder = path.join(configurableProperties.basePicturePath, picObj.user_ref);
  const pathToFile = path.join(pathToFolder, uuid);
  const stat = fs.statSync(pathToFile);

  res.writeHead(200, {
      'Content-Type': picObj.contentType,
      // 'Content-Length': stat.size
  });

  const readStream = fs.createReadStream(pathToFile);
  if (height) {
    const heightInt = parseInt(height);
    const resizeTransform = sharp().resize(null, heightInt).max();
    readStream.pipe(resizeTransform).pipe(res);
  } else {
    readStream.pipe(res);
  }
});

router.post('/', async (req, res, next) => {
  const {
    authorization,
    x_filename: filename,
    x_comment: comment,
    x_groupref: groupRefUnvalidated,
    x_grouprefname: groupRefName,
    'content-type': contentType
  } = req.headers;
  try {
    const userRef = await getUserRef(authorization);

    const pictureUUID = entropy.string();

    let picturegroupObj;
    if (groupRefUnvalidated) {
      picturegroupObj = await db.loadPicturegroup(groupRefUnvalidated);
      if(!picturegroupObj) {
        throw new Error(`Failed to load Picturegroup ${groupRefUnvalidated}`);
      }
      debug('Loaded Picturegroup = %s', picturegroupObj._id);
    }
    if (!picturegroupObj) {
      picturegroupObj = await db.createPicturegroup({ userRef, name: groupRefName });
      debug('Created Picturegroup with name = %s', groupRefName);
    }
    const groupRef = picturegroupObj._id;
    
    const newPicObj = await db.createPicture({
      comment,
      filename,
      contentType,
      userRef,
      groupRef,
      pictureUUID
    });
    debug('created newPicObj = %s', newPicObj._id);

    if(!picturegroupObj.picture_ref) {
      picturegroupObj.picture_ref = [];
    }
    picturegroupObj.picture_ref.push(pictureUUID);
    picturegroupObj.lastUpdatedOn = new Date();
    await db.storeObject(picturegroupObj);

    const pathToFolder = path.join(configurableProperties.basePicturePath, userRef);
    const pathToFile = path.join(pathToFolder, pictureUUID);
    await mkdirp(pathToFolder);

    const writeResult = await writeFile(pathToFile, req.body);
    
    res.send(newPicObj);
  } catch (err) {
    console.log(err);
    res.status(403).send({ error: err.message });
  }
});

module.exports = router;
