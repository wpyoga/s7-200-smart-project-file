"use strict";

// convention: "bytes" means Uint8Array

const fileElem = document.getElementById("projectfile");
const passwordElem = document.getElementById("password");
const hashElem = document.getElementById("hashtext");
const globalVTElem = document.getElementById("globalvartable");
const excelElem = document.getElementById("excelfile");
const templateElem = document.getElementById("exceltemplate");
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
let projectFilename;
let zipEntries;

// calculate the default password hash on startup
window.addEventListener("load", documentLoaded);

fileElem.addEventListener("change", fileUpdated);
passwordElem.addEventListener("input", passwordUpdated);
excelElem.addEventListener("change", excelUpdated);

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
        new zip.Uint8ArrayReader(new Uint8Array(zipData[i])),
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
    newFilename,
  );

  const newCiphertext = await encryptProjectData(newZipFile);

  const newProjectFile = new Uint8Array([
    ...bytes.subarray(0, 256),
    ...newCiphertext,
  ]);

  statusElem.textContent = "Project file processed and ready to download.";

  const newProjectBlob = new Blob([newProjectFile], {
    type: "application/smartv3",
  });
  if (downloadURL) URL.revokeObjectURL(downloadURL);
  // console.log(newProjectFile);
  downloadURL = URL.createObjectURL(newProjectBlob);
  // const newProjectFilename = "new.smartV3";
  const newProjectFilename = projectFilename;
  setContent(
    outputElem,
    "a",
    { href: downloadURL, download: newProjectFilename },
    newProjectFilename,
  );
}

async function getVTs() {
  // console.log(zipData);
  const xmlFile = await zipEntries
    .find((x) => x.filename.endsWith("m_mGlbVarTables.xml"))
    .arrayBuffer();
  // console.log(xmlFile);
  // console.log(new TextDecoder().decode(new Uint8Array(xmlFile)));
  const xmlDoc = new DOMParser().parseFromString(
    new TextDecoder().decode(new Uint8Array(xmlFile)),
    "application/xml",
  );
  // console.log(xmlDoc);
  // console.log(xmlDoc.getElementsByTagName("VarTable"));
  // console.log(xmlDoc.documentElement);
  // console.log(xmlDoc.documentElement.childNodes);
  const listVarTable = Array.from(xmlDoc.documentElement.childNodes).filter(
    (c) => c.localName === "VarTable",
  );
  // console.log(listVarTable);

  const wb = new ExcelTS.Workbook();

  // Variable Table
  // Retain configurable
  // Bind configurable
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "VT")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptyVT(wb, vtName);

      // recursively get all the members
      const getMembers = (ws, node, depth) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const inival = m.getAttribute("IniVal");
            const retain =
              m.getAttribute("Retain") === "1"
                ? { checkbox: true }
                : { checkbox: false };
            const bind =
              m.getAttribute("Bind") === "1"
                ? { checkbox: true }
                : { checkbox: false };
            const addr = m.getAttribute("Addr");
            const comment = m.getAttribute("Commt");

            ws.addRow([
              "> ".repeat(depth) + (name ?? ""),
              type,
              inival,
              retain,
              bind,
              addr,
              comment,
            ]).outlineLevel = depth;

            getMembers(ws, m, depth + 1);
          });
      };
      getMembers(ws, vt, 0);

      // console.log(ws.lastRow);

      const lastRowNum = ws.lastRow.number;
      for (let i = lastRowNum + 1; i <= lastRowNum + 100; ++i) {
        ws.getCell("D" + i).value = { checkbox: false };
        ws.getCell("E" + i).value = { checkbox: false };
      }
      for (let i = 2; i <= lastRowNum + 100; ++i) {
        ws.getCell("D" + i).dataValidation = {
          type: "list",
          allowBlank: true,
          formulae: ['"TRUE,FALSE"'],
        };
        ws.getCell("E" + i).dataValidation = {
          type: "list",
          allowBlank: true,
          formulae: ['"TRUE,FALSE"'],
        };
      }
    });

  // Constant Table
  // Retain always 0
  // Bind always 0
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "CONSTVT")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptyCONSTVT(wb, vtName);

      // get all the members
      const getMembers = (ws, node) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const inival = m.getAttribute("IniVal");
            const comment = m.getAttribute("Commt");
            ws.addRow([name, type, inival, comment]);
          });
      };
      getMembers(ws, vt);
    });

  // IO Variable
  // Retain always 0
  // Bind always 1
  // Addr is I/O point: Q2.3, I5.5, ...
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "IOS")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptyIOS(wb, vtName);

      // get all the members
      const getMembers = (ws, node) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const addr = m.getAttribute("Addr");
            const comment = m.getAttribute("Commt");
            ws.addRow([name, type, addr, comment]);
          });
      };
      getMembers(ws, vt);
    });

  // POU Table
  // Retain always 0
  // Bind always 1
  // Addr is POU identifier: OB1, SBR0, FB123, INT5, ...
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "POUVT")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptyPOUVT(wb, vtName);

      // get all the members
      const getMembers = (ws, node) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const addr = m.getAttribute("Addr");
            const comment = m.getAttribute("Commt");
            ws.addRow([name, type, addr, comment]);
          });
      };
      getMembers(ws, vt);
    });

  // System Variable Table
  // Retain always 0
  // Bind always 1
  // Addr is SM memory address
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "SDVT")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptySDVT(wb, vtName);

      // get all the members
      const getMembers = (ws, node) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const addr = m.getAttribute("Addr");
            const comment = m.getAttribute("Commt");
            ws.addRow([name, type, addr, comment]);
          });
      };
      getMembers(ws, vt);
    });

  // FB Instance Table
  // Retain configurable
  // Bind always 0
  listVarTable
    .filter((x) => x.getAttribute("TableType") === "FB")
    .forEach((vt) => {
      const vtName = vt.getAttribute("TableName");
      const ws = addEmptyFB(wb, vtName);

      // recursively get all the members
      const getMembers = (ws, node, depth) => {
        Array.from(node.children)
          .filter((m) => m.localName === "Member")
          .forEach((m) => {
            const name = m.getAttribute("Name");
            const type = m.getAttribute("DataType");
            const inival = m.getAttribute("IniVal");
            const retain =
              m.getAttribute("Retain") === "1"
                ? { checkbox: true }
                : { checkbox: false };
            const addr = m.getAttribute("Addr");
            const comment = m.getAttribute("Commt");

            ws.addRow([
              "> ".repeat(depth) + (name ?? ""),
              type,
              inival,
              retain,
              addr,
              comment,
            ]);

            getMembers(ws, m, depth + 1);
          });
      };
      getMembers(ws, vt, 0);

      // console.log(ws.lastRow);

      const lastRowNum = ws.lastRow.number;
      for (let i = lastRowNum + 1; i <= lastRowNum + 100; ++i) {
        ws.getCell("D" + i).value = { checkbox: false };
      }
      for (let i = 2; i <= lastRowNum + 100; ++i) {
        ws.getCell("D" + i).dataValidation = {
          type: "list",
          allowBlank: true,
          formulae: ['"TRUE,FALSE"'],
        };
      }
    });

  //
  //
  //
  const vtFile = await wb.xlsx.writeBuffer();
  // console.log(vtFile);
  const vtBlob = new Blob([vtFile], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const vtFilename = projectFilename.replace(/\.smartV3$/i, "") + ".xlsx";
  setContent(
    globalVTElem,
    "a",
    { href: URL.createObjectURL(vtBlob), download: vtFilename },
    vtFilename,
  );
}

async function hashPassword(password) {
  return await strToSha256(
    passwordProtected && password.length > 0 ? password : DEFAULT_PASSWORD,
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
      ciphertext,
    ),
  );
}

async function encryptProjectData(bytes) {
  return new Uint8Array(
    await window.crypto.subtle.encrypt(
      { name: "AES-GCM", iv: IV, additionalData: AAD, tagLength: 128 },
      key,
      bytes,
    ),
  );
}

async function processFile(file) {
  const reader = new FileReader();
  reader.onload = async (e) => {
    const bytes = new Uint8Array(e.target.result);
    projectFileValid = checkUploadedFile(bytes);
    // console.log(fileElem.value);
    if (projectFileValid) projectFilename = fileElem.value.split(/[/\\]/).pop();
    if (projectFileValid) await processProjectFile(bytes);
    // TODO: check the result of processProjectFile() instead
    if (projectFileValid) getVTs();
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

  // wsVT.addFormCheckbox("J2:K3", {
  //   checked: true,
  //   link: "D6",
  //   text: "hello",
  // });
  // wsVT.addFormCheckbox("J4:J4", {
  //   checked: true,
  //   link: "D7",
  //   text: "world",
  // });
  // wsVT.addFormCheckbox("J5:J5", {
  //   checked: true,
  //   link: "D8",
  //   text: "",
  // });
  // wsVT.addFormCheckbox("J6:J6", {
  //   checked: true,
  //   link: "D9",
  // });
  // wsVT.addFormCheckbox("J7", {
  //   checked: true,
  //   link: "D10",
  //   text: "world",
  // });
  // wsVT.addFormCheckbox("J8", {
  //   checked: true,
  //   link: "D11",
  //   text: "",
  // });
  // wsVT.addFormCheckbox("J9", {
  //   checked: true,
  //   link: "D12",
  // });

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
    templateFilename,
  );
}

// this is called on startup
async function documentLoaded() {
  passwordUpdated();
  generateExcelTemplate();
}

async function fileUpdated() {
  if (fileElem.files[0]) processFile(fileElem.files[0]);
}

async function passwordUpdated() {
  const password =
    passwordElem.value.length > 0 ? passwordElem.value : DEFAULT_PASSWORD;

  passwordHash = await strToSha256(password);

  setContent(hashElem, "code", null, bytesToHex(passwordHash));

  if (fileElem.files[0]) processFile(fileElem.files[0]);
}

async function excelUpdated() {
  if (excelElem.files[0]) processExcel(excelElem.files[0]);
}
