const stripe = require("stripe")(
  "sk_test_51LjME3JcZKN8LlIM5KNAdYF1UxSPFU7VhIvQKupoNaCxVzLcCsJSShR5RSMUgLQCxr3VzwzAcbFepQTpKppsi4Mk00bFyYOGiq"
);

exports.handler = async (event) => {
  // TODO implement

  event = JSON.parse(event.body);
  const paymentIntent = await stripe.paymentIntents.create({
    amount: event.total * 100,
    currency: "usd",
    automatic_payment_methods: { enabled: true },
  });

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      client_secret: paymentIntent.client_secret,
    }),
  };
  return response;
};
