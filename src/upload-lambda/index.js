const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const Busboy = require("busboy");
const { v4: uuidv4 } = require("uuid");

const s3 = new S3Client({ region: process.env.AWS_REGION || "us-east-1" });

const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"];
const MAX_SIZE_BYTES = 10 * 1024 * 1024;

exports.handler = async (event) => {
  try {
    const contentType =
      event.headers?.["content-type"] || event.headers?.["Content-Type"] || "";

    let fileBuffer, fileExt, fileMime;

    if (contentType.includes("multipart/form-data")) {
      const result = await parseMultipart(event, contentType);
      fileBuffer = result.fileBuffer;
      fileExt = result.fileExt;
      fileMime = result.fileMime;
    } else if (contentType.includes("application/json")) {
      const body = JSON.parse(
        event.isBase64Encoded
          ? Buffer.from(event.body, "base64").toString()
          : event.body
      );
      if (!body.image || !body.mimeType) {
        return response(400, { error: "Missing image or mimeType field" });
      }
      fileMime = body.mimeType;
      fileBuffer = Buffer.from(body.image, "base64");
      fileExt = extensionFromMime(fileMime);
    } else {
      return response(400, { error: "Unsupported Content-Type" });
    }

    if (!ALLOWED_TYPES.includes(fileMime)) {
      return response(400, { error: "File type not allowed" });
    }
    if (fileBuffer.length > MAX_SIZE_BYTES) {
      return response(400, { error: "File exceeds 10 MB limit" });
    }

    const key = `${process.env.UPLOAD_PREFIX}${uuidv4()}.${fileExt}`;
    await s3.send(
      new PutObjectCommand({
        Bucket: process.env.S3_BUCKET,
        Key: key,
        Body: fileBuffer,
        ContentType: fileMime,
        ServerSideEncryption: "AES256",
      })
    );

    return response(200, { message: "Upload successful", key });
  } catch (err) {
    console.error("Upload error:", err);
    return response(500, { error: "Internal server error" });
  }
};

function parseMultipart(event, contentType) {
  return new Promise((resolve, reject) => {
    const bb = Busboy({ headers: { "content-type": contentType } });
    let fileBuffer = null, fileExt = null, fileMime = null;

    bb.on("file", (name, stream, info) => {
      fileMime = info.mimeType;
      fileExt = extensionFromMime(fileMime);
      const chunks = [];
      stream.on("data", (d) => chunks.push(d));
      stream.on("end", () => (fileBuffer = Buffer.concat(chunks)));
    });
    bb.on("close", () => resolve({ fileBuffer, fileExt, fileMime }));
    bb.on("error", reject);

    const body = event.isBase64Encoded
      ? Buffer.from(event.body, "base64")
      : Buffer.from(event.body);
    bb.write(body);
    bb.end();
  });
}

function extensionFromMime(mime) {
  const map = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/gif": "gif",
    "image/webp": "webp",
  };
  return map[mime] || "bin";
}

function response(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  };
}