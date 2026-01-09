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

let passwordProtected = false;
let projectFileValid = false;
let downloadURL;
let passwordHash;

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
  const bytes = new TextEncoder().encode(str);
  return new Uint8Array(await window.crypto.subtle.digest("SHA-256", bytes));
}

// supports the following attributes: href, download
function setContent(parent, elemType, attr, str) {
  const elem = document.createElement(elemType);
  elem.textContent = str;
  if (attr) ["href", "download"].forEach((s) => attr[s] && (elem[s] = attr[s]));
  parent.textContent = "";
  parent.appendChild(elem);
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
    statusElem.textContent = "File does not look like a SMART V3 project file.";
    setContent(outputElem, "pre", null, hexDump(bytes, 1, 32));
    return false;
  }

  if (checkHex(bytes, 120, 2, "00 01")) passwordProtected = true;
  else if (checkHex(bytes, 120, 2, "00 02")) passwordProtected = false;
  else {
    statusElem.textContent = "File does not look like a SMART V3 project file.";
    setContent(outputElem, "pre", null, hexDump(bytes, 1, 32));
    return false;
  }

  return true;
}

// accept an arrayBuffer containing the file data
async function processProjectFile(bytes) {
  let plaintext;
  try {
    plaintext = await decryptProjectData(bytes, passwordProtected);
  } catch (err) {
    console.log(err);
    if (passwordProtected) {
      statusElem.textContent = "Decryption failure, check your password.";
    } else {
      statusElem.textContent = "Decryption failure: " + err;
    }
    outputElem.textContent = "";
    return;
  }

  // console.log("plaintext", plaintext);
  // console.log(new Uint8Array(plaintext));
  statusElem.textContent = "File decrypted successfully.";
  setContent(outputElem, "pre", null, hexDump(bytes, 1, 32));

  const zipReader = new zip.ZipReader(
    new zip.Uint8ArrayReader(new Uint8Array(plaintext))
  );
  let zipEntries;
  try {
    const filenameEncoding = "cp437";
    zipEntries = await zipReader.getEntries({ filenameEncoding });
  } catch (err) {
    console.log("err", err);
  }

  statusElem.textContent =
    "Successfully decrypted and unzipped, files shown below.";

  outputElem.textContent = "";
  const ul = document.createElement("ul");
  zipEntries.forEach((entry) => {
    const li = document.createElement("li");
    li.textContent = entry.filename;
    ul.appendChild(li);
  });
  outputElem.appendChild(ul);

  // console.log("entries", zipEntries);
  // const xmlFile = await zipEntries
  //   .find((x) => x.filename.endsWith("m_mGlbVarTables.xml"))
  //   .arrayBuffer();
  // console.log(new TextDecoder().decode(new Uint8Array(xmlFile)));

  // decompress the files
  const zipData = [];
  for (let i = 0; i < zipEntries.length; ++i) {
    if (zipEntries[i].directory) zipData.push(null);
    else zipData.push(await zipEntries[i].arrayBuffer());
  }

  // don't forget to close the zip archive
  await zipReader.close();

  const zipWriter = new zip.ZipWriter(new zip.Uint8ArrayWriter());
  for (let i = 0; i < zipEntries.length; ++i) {
    if (zipEntries[i].directory)
      zipWriter.add(zipEntries[i].filename, null, { directory: true });
    else
      zipWriter.add(
        zipEntries[i].filename,
        new zip.Uint8ArrayReader(new Uint8Array(zipData[i]))
      );
  }
  const newZipFile = await zipWriter.close();
  const zipBlob = new Blob([newZipFile], { type: "application/zip" });
  if (downloadURL) URL.revokeObjectURL(downloadURL);
  downloadURL = URL.createObjectURL(zipBlob);
  const newFilename = "new.zip";
  setContent(
    outputElem,
    "a",
    { href: downloadURL, download: newFilename },
    `Download: ${newFilename}`
  );
}

async function hashPassword(password) {
  return await strToSha256(
    passwordProtected && password.length > 0 ? password : DEFAULT_PASSWORD
  );
}

async function decryptProjectData(bytes, passwordProtected) {
  const keyBuf = passwordProtected
    ? passwordHash
    : await strToSha256(DEFAULT_PASSWORD);

  // console.log(keyBuf);
  const key = await window.crypto.subtle.importKey(
    "raw",
    keyBuf,
    "AES-GCM",
    true,
    ["encrypt", "decrypt"]
  );
  // console.log(key);
  // console.log(await window.crypto.subtle.exportKey("raw", key));

  const ciphertext = bytes.subarray(256);

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
  const password =
    passwordElem.value.length > 0 ? passwordElem.value : DEFAULT_PASSWORD;

  passwordHash = await strToSha256(password);

  setContent(hashElem, "code", null, bytesToHex(passwordHash));

  if (fileElem.files[0]) processFile(fileElem.files[0]);
}

async function fileUpdated() {
  if (fileElem.files[0]) processFile(fileElem.files[0]);
}
