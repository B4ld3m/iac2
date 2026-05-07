const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const sharp = require("sharp");
const path = require("path");

const s3 = new S3Client({ region: process.env.AWS_REGION || "us-east-1" });
const SIZE = 40;

exports.handler = async (event) => {
  const results = [];

  for (const record of event.Records) {
    const messageId = record.messageId;
    try {
      const body = JSON.parse(record.body);
      const s3Records = body.Records || [];

      for (const s3Record of s3Records) {
        const srcKey = decodeURIComponent(
          s3Record.s3.object.key.replace(/\+/g, " ")
        );
        const bucket = s3Record.s3.bucket.name;

        const getCmd = new GetObjectCommand({ Bucket: bucket, Key: srcKey });
        const s3Obj = await s3.send(getCmd);
        const inputBuffer = await streamToBuffer(s3Obj.Body);

        const circleSvg = Buffer.from(
          `<svg width="${SIZE}" height="${SIZE}">
            <circle cx="${SIZE/2}" cy="${SIZE/2}" r="${SIZE/2}" fill="white"/>
          </svg>`
        );

        const outputBuffer = await sharp(inputBuffer)
          .resize(SIZE, SIZE, { fit: "cover", position: "centre" })
          .composite([{ input: circleSvg, blend: "dest-in" }])
          .png()
          .toBuffer();

        const baseName = path.basename(srcKey, path.extname(srcKey));
        const destKey = `${process.env.PROCESSED_PREFIX}${baseName}_circular.png`;

        await s3.send(
          new PutObjectCommand({
            Bucket: bucket,
            Key: destKey,
            Body: outputBuffer,
            ContentType: "image/png",
            ServerSideEncryption: "AES256",
          })
        );
      }
    } catch (err) {
      console.error(`Error processing message ${messageId}:`, err);
      results.push({ itemIdentifier: messageId });
    }
  }

  return { batchItemFailures: results };
};

function streamToBuffer(stream) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    stream.on("data", (chunk) => chunks.push(chunk));
    stream.on("end", () => resolve(Buffer.concat(chunks)));
    stream.on("error", reject);
  });
}