"use strict";

const passwordElem = document.getElementById("password");
const hashElem = document.getElementById("hashtext");
const fileElem = document.getElementById("projectfile");
const statusElem = document.getElementById("status");
const outputElem = document.getElementById("output");

var passwordProtected = false;
var projectFileValid = false;

// accepts a well-formatted hex string and returns an integer array
// all whitespace is stripped from the hex string
// results are undefined otherwise
function hexStrToArray(str) {
  return str
    .replace(/\s+/g, "")
    .match(/../g)
    .map((x) => parseInt(x, 16));
}

function hexStrToBuf(str) {
  return new Uint8Array(hexStrToArray(str)).buffer;
}

async function sha256str(str) {
  var buf = new TextEncoder().encode(str);
  return await window.crypto.subtle.digest("SHA-256", buf);
}

function arrayHexView(arr, spaces = 1, cols = 16) {
  view = new Array();
  return arr
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
    .match(new RegExp(".{1," + cols + "}", "g"))
    .map((line) => line.match(/../g).join(" ".repeat(spaces)))
    .join("\n");
}

function arrayToHexStr(arr, spaces = 0, cols = 0) {
  if (cols !== 0) {
    return arr
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("")
      .match(new RegExp(".{1," + cols + "}", "g"))
      .map((line) => line.match(/../g).join(" ".repeat(spaces)))
      .join("\n");
  } else
    return arr
      .map((b) => b.toString(16).padStart(2, "0"))
      .join(" ".repeat(spaces));
}

function arrayCompare(arr1, arr2) {
  console.log("compare");
  console.log(arr1);
  console.log(arr2);
  return (
    arr1.length === arr2.length &&
    arr1.every((val, idx) => {
      console.log("val, idx", val, idx, val === arr2[idx]);
      return val === arr2[idx];
    })
  );
}

function checkNulls(buf, start, len) {
  return arrayCompare(
    new Uint8Array(buf).subarray(start, start + len),
    new Array(len).fill(0)
  );
}

function checkString(buf, start, len, str) {
  console.log("checkString", buf.slice(start, start + len));
  console.log(new TextEncoder().encode(str));
  return arrayCompare(
    new Uint8Array(buf).subarray(start, start + len),
    new TextEncoder().encode(str)
  );
}

function checkStrings(buf, start, len, strArray) {
  return !strArray.every((str) => !checkString(buf, start, len, str));
}

function checkHex(buf, start, len, hexStr) {
  // console.log(buf);
  // console.log(hexStr);
  // console.log(hexStrToArray(hexStr));
  return arrayCompare(
    new Uint8Array(buf).subarray(start, start + len),
    hexStrToArray(hexStr)
  );
}

function checkUploadedFile(buf) {
  // check the file contents
  if (
    !checkNulls(buf, 0, 4) ||
    !checkStrings(buf, 4, 12, ["R03.00.00.00", "R03.01.00.00"]) ||
    !checkNulls(buf, 16, 104) ||
    !checkNulls(buf, 122, 134)
  ) {
    statusElem.innerHTML = "File does not look like a SMART V3 project file.";
    outputElem.innerHTML =
      "<pre>" +
      arrayToHexStr(Array.from(new Uint8Array(buf)), 1, 64) +
      "</pre>";
    return false;
  }

  if (checkHex(buf, 120, 2, "00 01")) passwordProtected = true;
  else if (checkHex(buf, 120, 2, "00 02")) passwordProtected = false;
  else {
    statusElem.innerHTML = "File does not look like a SMART V3 project file.";
    outputElem.innerHTML =
      "<pre>" +
      arrayToHexStr(Array.from(new Uint8Array(buf)), 1, 64) +
      "</pre>";
    return false;
  }

  return true;
}

// accept an arrayBuffer containing the file data
async function processProjectFile(buf) {
  try {
    var plaintext = await decryptProjectData(buf, passwordProtected);
  } catch (err) {
    console.log(err);
    if (passwordProtected) {
      statusElem.innerText = "Decryption failure, check your password.";
    } else {
      statusElem.innerText = "Decryption failure: " + err;
    }
    outputElem.innerHTML = "";
    return;
  }

  console.log("plaintext", plaintext);
  console.log(new Uint8Array(plaintext));
  statusElem.innerText = "File decrypted successfully.";
  outputElem.innerHTML =
    "<pre>" +
    arrayToHexStr(Array.from(new Uint8Array(plaintext)), 1, 64) +
    "</pre>";
}

async function decryptProjectData(buf, passwordProtected) {
  var keyBuf;
  if (passwordProtected) {
    var password = passwordElem.value;
    if (password.length === 0) password = DEFAULT_PASSWORD;
    keyBuf = await window.crypto.subtle.digest(
      "SHA-256",
      new TextEncoder().encode(password)
    );
  } else {
    keyBuf = await window.crypto.subtle.digest(
      "SHA-256",
      new TextEncoder().encode(DEFAULT_PASSWORD)
    );
  }

  keyBuf = new Uint8Array(keyBuf);
  console.log(keyBuf);
  var key = await window.crypto.subtle.importKey(
    "raw",
    keyBuf,
    "AES-GCM",
    true,
    ["encrypt", "decrypt"]
  );
  console.log(key);
  console.log(await window.crypto.subtle.exportKey("raw", key));

  var ciphertext = buf.slice(256);
  // var ciphertext = new Uint8Array(buf.slice(256));
  // console.log(ciphertext);

  return window.crypto.subtle.decrypt(
    { name: "AES-GCM", iv: IV, additionalData: AAD, tagLength: 128 },
    key,
    ciphertext
  );
}

function processFile() {
  var file = fileElem.files[0];
  const reader = new FileReader();
  reader.onload = (e) => {
    projectFileValid = checkUploadedFile(e.target.result);
    if (projectFileValid) processProjectFile(e.target.result);
  };
  reader.readAsArrayBuffer(file);
}

async function passwordUpdated() {
  var password = passwordElem.value;
  if (password.length === 0) password = DEFAULT_PASSWORD;
  sha256str(password).then((hashBuf) => {
    hashElem.innerHTML =
      "<code>" + arrayToHexStr(Array.from(new Uint8Array(hashBuf))) + "</code>";
  });

  if (fileElem.files) processFile();
}

function fileUpdated() {
  processFile();
}

const IV = hexStrToBuf("95 A6 34 68 4A 46 A9 70 EE 90 76 49");
const AAD = hexStrToBuf("4A 14 B3 A5 7B C9 F4 92 EB 46 87 94 62 EF B9 C6");
const DEFAULT_PASSWORD = "SMART200_V3_PRJ_KEY";
