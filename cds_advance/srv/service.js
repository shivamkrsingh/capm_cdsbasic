const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const {
    SalesOrders,
    SalesOrderItems,
    CurrencyRate
  } = this.entities;

  // Multi-Currency Conversion
  this.before('CREATE', SalesOrderItems, async (req) => {

    if (req.data.currency !== 'USD') {

      const rate = await SELECT.one.from(CurrencyRate)
        .where({
          sourceCurrency: req.data.currency,
          targetCurrency: 'USD'
        });

      if (rate) {
        req.data.price *= rate.rate;
        req.data.currency = 'USD';
      }
    }
  });

  // Recalculate Total
  this.after(['CREATE', 'UPDATE'], SalesOrderItems, async (req) => {

    const orderId = req.data.parent_ID;

    const items = await SELECT.from(SalesOrderItems)
      .where({ parent_ID: orderId });

    let total = 0;
    items.forEach(i => total += i.price * i.quantity);

    await UPDATE(SalesOrders)
      .set({ totalAmount: total })
      .where({ ID: orderId });
  });

  // Event Emit
  this.after('CREATE', SalesOrders, async (data) => {
    await this.emit('SalesOrder.Created', data);
  });

});