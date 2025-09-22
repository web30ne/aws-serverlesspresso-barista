const AWS = require('aws-sdk');
const eb = new AWS.EventBridge();

exports.handler = async (event) => {
  const detail = JSON.stringify({
    orderId: 'ord-123',
    userId: 'lex-user',
    items: [{ id: event.sessionState.intent.slots.drink.value.interpretedValue, qty: 1 }],
    total: 3.5,
    timestamp: new Date().toISOString()
  });

  await eb.putEvents({
    Entries: [{
      Source: 'serverlesscoffee.order',
      DetailType: 'OrderPlaced',
      Detail: detail,
      EventBusName: 'Serverlesspresso'
    }]
  }).promise();

  return {
    sessionState: {
      dialogAction: { type: 'Close' },
      intent: {
        name: 'OrderCoffee',
        state: 'Fulfilled'
      }
    },
    messages: [{ contentType: 'PlainText', content: 'Your coffee is on the way!' }]
  };
};