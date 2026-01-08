"use strict";

// convention: "bytes" means Uint8Array

const passwordElem = document.getElementById("password");
const hashElem = document.getElementById("hashtext");
const fileElem = document.getElementById("projectfile");
const statusElem = document.getElementById("status");
const outputElem = document.getElementById("output");

// these are static defaults as mandated by the original program
// IV and AAD are not secrets, the default password is used only for non-protected projects
const IV = hexToBytes("95 A6 34 68 4A 46 A9 70 EE 90 76 49");
const AAD = hexToBytes("4A 14 B3 A5 7B C9 F4 92 EB 46 87 94 62 EF B9 C6");
const DEFAULT_PASSWORD = "SMART200_V3_PRJ_KEY";

var passwordProtected = false;
var projectFileValid = false;

// calculate the default password hash on startup
window.addEventListener("load", documentLoaded);

passwordElem.addEventListener("input", passwordUpdated);
fileElem.addEventListener("change", fileUpdated);

// accepts a well-formatted hex string and returns an integer array
// all whitespace is stripped from the hex string
// results are undefined otherwise
function hexToBytes(str) {
  return new Uint8Array(
    str
      .replace(/\s+/g, "")
      .match(/../g)
      .map((x) => parseInt(x, 16))
  );
}

async function strToSha256(str) {
  var bytes = new TextEncoder().encode(str);
  return new Uint8Array(await window.crypto.subtle.digest("SHA-256", bytes));
}

function minimalEscapePre(str) {
  return "<pre>" + str.replace(/&/g, "&amp;").replace(/</g, "&lt;") + "</pre>";
}

// convert bytes into xxd-like hexdump
function hexDump(bytes, spaces = 1, cols = 16) {
  const lines = [];
  const printable = (b) =>
    b >= 0x20 && b <= 0x7e ? String.fromCharCode(b) : ".";

  for (let pos = 0; pos < bytes.length; pos += cols) {
    const subarray = bytes.subarray(pos, pos + cols);
    const offset = pos.toString(16).padStart(8, "0");
    let hex = bytesToHex(subarray, spaces);
    const ascii = Array.from(subarray, printable).join("");

    // special treatment for the last line
    if (pos + cols > bytes.length)
      hex += " ".repeat((pos + cols - bytes.length) * (2 + spaces));

    lines.push(offset + ": " + hex + "  " + ascii);
  }

  return lines.join("\n");
}

function bytesToHex(bytes, spaces = 0, cols = 0) {
  const arr = Array.from(bytes);
  if (cols !== 0) {
    return arr
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("")
      .match(new RegExp(".{1," + cols + "}", "g"))
      .map((line) => line.match(/../g).join(" ".repeat(spaces)))
      .join("\n");
  } else {
    return arr
      .map((b) => b.toString(16).padStart(2, "0"))
      .join(" ".repeat(spaces));
  }
}

function bytesCompare(bytes1, bytes2) {
  // console.log("compare");
  // console.log(arr1);
  // console.log(arr2);
  return (
    bytes1.length === bytes2.length &&
    bytes1.every((val, idx) => {
      // console.log("val, idx", val, idx, val === bytes2[idx]);
      return val === bytes2[idx];
    })
  );
}

function checkNulls(bytes, start, len) {
  if (bytes.length < start + len) return false;
  return bytesCompare(
    bytes.subarray(start, start + len),
    new Uint8Array(len).fill(0)
  );
}

function checkString(bytes, start, len, str) {
  // console.log("checkString", bytes.subarray(start, start + len));
  // console.log(new TextEncoder().encode(str));
  if (bytes.length < start + len || len !== str.length) return false;
  return bytesCompare(
    bytes.subarray(start, start + len),
    new TextEncoder().encode(str)
  );
}

function oneOfStrings(bytes, start, len, strArray) {
  return strArray.some((str) => checkString(bytes, start, len, str));
}

function checkHex(bytes, start, len, hexStr) {
  // console.log(bytes);
  // console.log(hexStr);
  // console.log(hexStrToArray(hexStr));
  return bytesCompare(
    new Uint8Array(bytes).subarray(start, start + len),
    hexToBytes(hexStr)
  );
}

function checkUploadedFile(bytes) {
  // check the file contents
  if (
    !checkNulls(bytes, 0, 4) ||
    !oneOfStrings(bytes, 4, 12, ["R03.00.00.00", "R03.01.00.00"]) ||
    !checkNulls(bytes, 16, 104) ||
    !checkNulls(bytes, 122, 134)
  ) {
    statusElem.innerHTML = "File does not look like a SMART V3 project file.";
    outputElem.innerHTML = minimalEscapePre(hexDump(bytes, 1, 32));
    return false;
  }

  if (checkHex(bytes, 120, 2, "00 01")) passwordProtected = true;
  else if (checkHex(bytes, 120, 2, "00 02")) passwordProtected = false;
  else {
    statusElem.innerHTML = "File does not look like a SMART V3 project file.";
    outputElem.innerHTML = minimalEscapePre(hexDump(bytes, 1, 32));
    return false;
  }

  return true;
}

// accept an arrayBuffer containing the file data
async function processProjectFile(bytes) {
  try {
    var plaintext = await decryptProjectData(bytes, passwordProtected);
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

  // console.log("plaintext", plaintext);
  // console.log(new Uint8Array(plaintext));
  statusElem.innerText = "File decrypted successfully.";
  outputElem.innerHTML = minimalEscapePre(hexDump(plaintext, 1, 32));

  var zipReader = new zip.ZipReader(
    new zip.Uint8ArrayReader(new Uint8Array(plaintext))
  );
  var zipEntries;
  try {
    const filenameEncoding = "cp437";
    zipEntries = await zipReader.getEntries({ filenameEncoding });
  } catch (err) {
    console.log("err", err);
  }

  statusElem.innerText =
    "Successfully decrypted and unzipped, files shown below.";
  outputElem.innerHTML =
    "<ul>" +
    zipEntries.map((entry) => "<li>" + entry.filename + "</li>").join("") +
    "</ul>";

  // console.log("entries", zipEntries);
  var xmlFile = await zipEntries
    .find((x) => x.filename.endsWith("m_mGlbVarTables.xml"))
    .arrayBuffer();
  // console.log(new TextDecoder().decode(new Uint8Array(xmlFile)));

  // don't forget to close the zip archive
  await zipReader.close();
}

async function decryptProjectData(bytes, passwordProtected) {
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
  // console.log(keyBuf);
  var key = await window.crypto.subtle.importKey(
    "raw",
    keyBuf,
    "AES-GCM",
    true,
    ["encrypt", "decrypt"]
  );
  // console.log(key);
  // console.log(await window.crypto.subtle.exportKey("raw", key));

  var ciphertext = bytes.subarray(256);
  // var ciphertext = new Uint8Array(bytes.subarray(256));
  // console.log(ciphertext);

  return window.crypto.subtle.decrypt(
    { name: "AES-GCM", iv: IV, additionalData: AAD, tagLength: 128 },
    key,
    ciphertext
  );
}

async function processFile(file) {
  const reader = new FileReader();
  reader.onload = async (e) => {
    const bytes = new Uint8Array(e.target.result);
    projectFileValid = checkUploadedFile(bytes);
    if (projectFileValid) processProjectFile(bytes);
  };
  reader.readAsArrayBuffer(file);
}

async function documentLoaded() {
  passwordUpdated();
}

async function passwordUpdated() {
  var password = passwordElem.value;
  if (password.length === 0) password = DEFAULT_PASSWORD;
  strToSha256(password).then((hashBuf) => {
    hashElem.innerHTML =
      "<code>" + bytesToHex(Array.from(new Uint8Array(hashBuf))) + "</code>";
  });

  if (fileElem.files[0]) processFile(fileElem.files[0]);
}

async function fileUpdated() {
  if (fileElem.files[0]) processFile(fileElem.files[0]);
}
