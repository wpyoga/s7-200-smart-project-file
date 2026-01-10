"use strict";

// convention: "bytes" means Uint8Array

const excelElem = document.getElementById("excelfile");
const templateElem = document.getElementById("exceltemplate");
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
let key;

// calculate the default password hash on startup
window.addEventListener("load", documentLoaded);

excelElem.addEventListener("change", excelUpdated);
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
  statusElem.textContent = "File decrypted successfully.";
  setContent(outputElem, "pre", null, hexDump(bytes, 1, 32));

  const zipReader = new zip.ZipReader(new zip.Uint8ArrayReader(plaintext));
  let zipEntries;
  try {
    const filenameEncoding = "cp437";
    zipEntries = await zipReader.getEntries({ filenameEncoding });
  } catch (err) {
    console.log("err", err);
    return;
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

  const newCiphertext = await encryptProjectData(newZipFile);

  const newProjectFile = new Uint8Array([
    ...bytes.subarray(0, 256),
    ...newCiphertext,
  ]);

  const newProjectBlob = new Blob([newProjectFile], {
    type: "application/smartv3",
  });
  if (downloadURL) URL.revokeObjectURL(downloadURL);
  // console.log(newProjectFile);
  downloadURL = URL.createObjectURL(newProjectBlob);
  const newProjectFilename = "new.smartV3";
  setContent(
    outputElem,
    "a",
    { href: downloadURL, download: newProjectFilename },
    "Download: " + newProjectFilename
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
  key = await window.crypto.subtle.importKey("raw", keyBuf, "AES-GCM", true, [
    "encrypt",
    "decrypt",
  ]);
  // console.log(key);
  // console.log(await window.crypto.subtle.exportKey("raw", key));

  const ciphertext = bytes.subarray(256);

  return new Uint8Array(
    await window.crypto.subtle.decrypt(
      { name: "AES-GCM", iv: IV, additionalData: AAD, tagLength: 128 },
      key,
      ciphertext
    )
  );
}

async function encryptProjectData(bytes) {
  return new Uint8Array(
    await window.crypto.subtle.encrypt(
      { name: "AES-GCM", iv: IV, additionalData: AAD, tagLength: 128 },
      key,
      bytes
    )
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

async function processExcel(file) {
  const reader = new FileReader();
  reader.onload = async (e) => {
    const bytes = new Uint8Array(e.target.result);
    const wb = new ExcelTS.Workbook();
    wb.xlsx.load(bytes);

    console.log(wb);
  };
  reader.readAsArrayBuffer(file);
}

async function generateExcelTemplate() {
  const wb = new ExcelTS.Workbook();

  const wsVT = wb.addWorksheet("Variable Table 1");

  const wsCT = wb.addWorksheet("Constant Table 1");

  wsVT.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Initial Value", key: "value", width: 16 },
    { header: "Retain", key: "retain", width: 8 },
    { header: "Bind", key: "bind", width: 8 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  wsCT.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Value", key: "value", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  wsVT.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  wsVT.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  wsVT.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Initial Value
  wsVT.getColumn("C").style = {
    numFmt: "@",
    font: { color: { argb: "FF808000" } },
    alignment: { horizontal: "left" },
  };

  // Retain
  wsVT.getColumn("D").style = {
    alignment: { horizontal: "center" },
  };

  // Bind
  wsVT.getColumn("E").style = {
    alignment: { horizontal: "center" },
  };

  // Address
  wsVT.getColumn("F").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  wsVT.getColumn("G").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  wsVT.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  // Initial sample data
  wsVT.getCell("D2").value = { checkbox: true };
  wsVT.getCell("E2").value = { checkbox: false };
  wsVT.getCell("D3").value = { checkbox: false };
  wsVT.getCell("E3").value = { checkbox: true };
  wsVT.getCell("D4").value = { checkbox: true };
  wsVT.getCell("E4").value = { checkbox: true };
  wsVT.getCell("D5").value = { checkbox: false };
  wsVT.getCell("E5").value = { checkbox: false };

  wsCT.getRow(1).fill = {
    type: "pattern",
    pattern: "solid",
    fgColor: { argb: "FFBBBBBB" },
  };

  const templateFile = await wb.xlsx.writeBuffer();
  // console.log(templateFile);
  const templateBlob = new Blob([templateFile], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const templateFilename = "template.xlsx";
  setContent(
    templateElem,
    "a",
    { href: URL.createObjectURL(templateBlob), download: templateFilename },
    "Download: " + templateFilename
  );
}

async function documentLoaded() {
  passwordUpdated();
  generateExcelTemplate();
}

async function excelUpdated() {
  if (excelElem.files[0]) processExcel(excelElem.files[0]);
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
