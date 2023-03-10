var nodemailer = require("nodemailer");
const responseHeaders = require("../../common/headers").headers;
exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  var transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  var mailOptions = {
    from: "drocker3738@gmail.com",
    to: "rockaflacka47.com",
    subject: "Successfully processed your order",
    text: "Order processed!",
  };

  let statusCode = 500;
  transporter.sendMail(mailOptions, function (error, info) {
    if (error) {
      console.log(error);
    } else {
      statusCode = 200;
      console.log("Email sent: " + info.response);
    }
  });

  const response = {
    statusCode: statusCode,
    headers: responseHeaders,
  };

  return response;
};
