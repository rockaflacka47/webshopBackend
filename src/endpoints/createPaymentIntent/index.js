require("dotenv").config();

const stripe = require("stripe")(process.env.STRIPE_KEY);

exports.handler = async (event) => {
  event = JSON.parse(event.body);
  const paymentIntent = await stripe.paymentIntents.create({
    amount: parseInt((event.total * 100).toString()),
    currency: "usd",
    metadata: {
      email: event.email,
    },
    automatic_payment_methods: { enabled: true },
  });

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST",
    },
    body: JSON.stringify({
      client_secret: paymentIntent.client_secret,
    }),
  };
  return response;
};
