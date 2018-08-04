const { promisify } = require('util');
const bcrypt = require('bcryptjs');

const configurableProperties = require('../services/configurableProperties');

const nano = require('nano')(configurableProperties.couchdbUrl);

const bcryptHash = promisify(bcrypt.hash);


const view = promisify(nano.view);
const insert = promisify(nano.insert);
const get = promisify(nano.get);

class DB {
  async loadUser(email) {
    return view('users', 'byEmailToObj', {
      'key': email.toLowerCase().trim(),
      'include_docs': true
    }).then(body => body.rows).then(rows => {
      if (rows.length == 0) {
        return null;
      } else {
        return rows[0].doc;
      }
    });
  }

  async storeObject(userObj) {
    return insert(userObj);
  }

  async initialObjectUser(userObj) {
    const creationResult = await insert(userObj);
    if (creationResult.ok !== true) {
      throw new Error('Failed to create new obj');
    }
    userObj._id = creationResult.id;
    userObj._rev = creationResult.rev;
    return userObj;
  }

  async createUser({ email, password }) {
    const newUserObj = {
      type: 'user',
      email,
      createdOn: new Date(),
      lastLogin: new Date(),
      lastPasswordChange: new Date(),
      failedLoginCount: 0,
      lastFailedLogin: null
    };
    const passwordHash = await bcryptHash(password, 8);
    newUserObj.passwordHash = passwordHash;
    return this.initialObjectUser(newUserObj);
  }

  async createPicture({ filename, comment, userRef, groupRef, contentType, pictureUUID }) {
    const newPictureObj = {
      type: 'picture',
      filename,
      comment,
      contentType,
      createdOn: new Date(),
      user_ref: userRef,
      group_ref: groupRef,
      pictureUUID
    };
    return this.initialObjectUser(newPictureObj); 
  }

  async loadPictureByUUID(uuid) {
    return view('pictures', 'byUUIDToObj', {
      'key': uuid,
      'include_docs': true
    }).then(body => body.rows).then(rows => {
      if (rows.length == 0) {
        return null;
      } else {
        return rows[0].doc;
      }
    });
  }

  async loadPicturegroup(id) {
    try {
      const loadedObj = await get(id);
      if (loadedObj.type !== 'picturegroup') {
        throw new Error('Loaded obj with wrong type');
      }
      return loadedObj;
    } catch (err) {
      if (err.statusCode === 404) {
        return null;
      }
      throw err;
    }
  }

  async createPicturegroup({ userRef, name }) {
    if(!name || !userRef) {
      throw new Error('Missing req parameters!');
    }
    const newPicturegroupObj = {
      type: 'picturegroup',
      name,
      createdOn: new Date(),
      lastUpdatedOn: new Date(),
      user_ref: userRef
    };
    return this.initialObjectUser(newPicturegroupObj);
  }

  async loadPicturegroups(userRef) {
    return view('picturegroups', 'byUserrefToObj', {
      'key': userRef,
      'include_docs': true
    }).then(body => body.rows.map(e => e.doc));
  }

  async loadPicturegroupsSummary(userRef) {
    return view('picturegroups', 'byUserrefToName', {
      'key': userRef,
      'include_docs': false
    }).then(body => body.rows.map(e => e.value));
  }

}

module.exports = new DB();
