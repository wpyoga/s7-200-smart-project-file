"use strict";

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

function addEmptyVT(wb, sheetName) {
  const ws = wb.addWorksheet("VT#" + sheetName);

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Initial Value", key: "value", width: 16 },
    { header: "Retain", key: "retain", width: 8 },
    { header: "Bind", key: "bind", width: 8 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Initial Value
  ws.getColumn("C").style = {
    numFmt: "@",
    font: { color: { argb: "FF808000" } },
    alignment: { horizontal: "left" },
  };

  // Retain
  ws.getColumn("D").style = {
    alignment: { horizontal: "center" },
  };

  // Bind
  ws.getColumn("E").style = {
    alignment: { horizontal: "center" },
  };

  // Address
  ws.getColumn("F").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("G").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}

function addEmptyCONSTVT(wb, sheetName) {
  const ws = wb.addWorksheet("CONSTVT#" + sheetName);

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Value", key: "value", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Value
  ws.getColumn("C").style = {
    numFmt: "@",
    // font: { color: { argb: "FF808000" } },
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("D").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}

function encodeSheetName(str) {
  // %  *  ?  :  \  /  [  ]
  // 25 2A 3F 3A 5C 2F 5B 5D
  return str
    .replace("%", "%25")
    .replace("*", "%2A")
    .replace("?", "%3F")
    .replace(":", "%3A")
    .replace("\\", "%5C")
    .replace("/", "%2F")
    .replace("[", "%5B")
    .replace("]", "%5D");
}

function addEmptyIOS(wb, sheetName) {
  const ws = wb.addWorksheet("IOS#" + encodeSheetName(sheetName));

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Address
  ws.getColumn("C").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("D").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}

function addEmptyPOUVT(wb, sheetName) {
  const ws = wb.addWorksheet("POUVT#" + sheetName);

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "POU Type", key: "type", width: 16 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Address
  ws.getColumn("C").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("D").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}

function addEmptySDVT(wb, sheetName) {
  const ws = wb.addWorksheet("SDVT#" + sheetName);

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Address
  ws.getColumn("C").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("D").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}

function addEmptyFB(wb, sheetName) {
  const ws = wb.addWorksheet("FB#" + sheetName);

  ws.columns = [
    { header: "Variable Name", key: "name", width: 24 },
    { header: "Data Type", key: "type", width: 16 },
    { header: "Initial Value", key: "value", width: 16 },
    { header: "Retain", key: "retain", width: 8 },
    { header: "Address", key: "address", width: 16 },
    { header: "Comment", key: "comment", width: 24 },
  ];

  ws.getRow(1).fill = {
    type: "gradient",
    gradient: "angle",
    degree: 90,
    stops: [
      { position: 0, color: { argb: "FFEEEEEE" } },
      { position: 1, color: { argb: "FFBBBBBB" } },
    ],
  };

  // Variable Name
  ws.getColumn("A").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Data Type
  ws.getColumn("B").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Initial Value
  ws.getColumn("C").style = {
    numFmt: "@",
    font: { color: { argb: "FF808000" } },
    alignment: { horizontal: "left" },
  };

  // Retain
  ws.getColumn("D").style = {
    alignment: { horizontal: "center" },
  };

  // Address
  ws.getColumn("E").style = {
    numFmt: "@",
    alignment: { horizontal: "left" },
  };

  // Comment
  ws.getColumn("F").style = {
    numFmt: "@",
    font: { color: { argb: "FF008000" } },
    alignment: { horizontal: "left" },
  };

  // Header is left-aligned
  ws.getRow(1).style = {
    alignment: { horizontal: "left" },
  };

  return ws;
}
