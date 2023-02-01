const AWS = require("aws-sdk");

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const BUCKET_NAME = "rocker-commerce";
  const IAM_USER_KEY = "AKIARTNSI7EVKDVXD5CI";
  const IAM_USER_SECRET = "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";
  const s3bucket = new AWS.S3({
    accessKeyId: IAM_USER_KEY,
    secretAccessKey: IAM_USER_SECRET,
  });

  event = JSON.parse(event.body);
  let name = event.fileName;
  const expirationInSeconds = 120;

  const params = {
    Bucket: BUCKET_NAME,
    Key: name,
    ContentType: "multipart/form-data",
    Expires: expirationInSeconds,
  };

  const preSignedURL = s3bucket.getSignedUrl("putObject", params);

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST",
    },
    body: JSON.stringify({
      fileUploadURL: preSignedURL,
    }),
  };

  return response;
};
