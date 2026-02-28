const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const { SalesOrder, SalesOrderItem, CurrencyRate } = this.entities;

    /* =========================
       Multi-Currency Conversion
    ========================== */

    this.before('CREATE', SalesOrderItem, async (req) => {

        if (req.data.currency !== 'USD') {

            const rate = await SELECT.one.from(CurrencyRate)
                .where({
                    sourceCurrency: req.data.currency,
                    targetCurrency: 'USD'
                });

            if (rate) {
                req.data.price = req.data.price * rate.rate;
                req.data.currency = 'USD';
            }
        }
    });

    /* =========================
       Real-Time Total Recalc
    ========================== */

    this.after(['CREATE','UPDATE'], SalesOrderItem, async (req) => {

        const orderId = req.data.parent_ID;

        const items = await SELECT.from(SalesOrderItem)
            .where({ parent_ID: orderId });

        let total = 0;
        items.forEach(i => total += i.price * i.quantity);

        await UPDATE(SalesOrder)
            .set({ totalAmount: total })
            .where({ ID: orderId });
    });

    /* =========================
       Event Mesh Emit
    ========================== */

    this.after('CREATE', SalesOrder, async (data) => {

        await this.emit('SalesOrder.Created', data);
    });

});