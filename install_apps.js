#!/usr/bin/env node

const { promisify } = require('util');
const { exit } = require('process');
const nativefierCB = require('nativefier').default;
const nativefier = promisify(nativefierCB);

const defaults = {
  out: 'temp',
  overwrite: false,
  singleInstance: true
};

const apps = [
  {
    name: 'Inbox',
    targetUrl: 'https://inbox.google.com',
    counter: true,
    bounce: true
  }
];

Promise.all(apps.map(app => nativefier({
    ...defaults,
    ...app
  })
  .then(appPath => {
    console.log(`App has been nativefied to ${appPath}`);
  })
  .catch(err => Promise.reject(err))
))
.catch(err => {
  console.log(err);
  exit(1);
});
