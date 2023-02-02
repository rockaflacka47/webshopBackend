const AWS = require("aws-sdk");
const responseHeaders = require("../../common/headers").headers;
require("dotenv").config();
exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const s3bucket = new AWS.S3({
    accessKeyId: process.env.IAM_USER_KEY,
    secretAccessKey: process.env.IAM_USER_SECRET,
  });

  event = JSON.parse(event.body);
  let name = event.fileName;
  const expirationInSeconds = 120;

  const params = {
    Bucket: process.env.BUCKET_NAME,
    Key: name,
    ContentType: "multipart/form-data",
    Expires: expirationInSeconds,
  };

  const preSignedURL = s3bucket.getSignedUrl("putObject", params);

  const response = {
    statusCode: 200,
    headers: responseHeaders,
    body: JSON.stringify({
      fileUploadURL: preSignedURL,
    }),
  };

  return response;
};
